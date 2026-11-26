# Aroon Money Flow Confluence [MarkitTick]

- url: https://www.tradingview.com/script/ZfJ2hD57-Aroon-Money-Flow-Confluence-MarkitTick/
- type: indicator
- pine_id: PUB;ba24bd73592542bf81b31d66ed1f35f1
- version: 1.0

## Description

💡 This indicator reads trend direction from two independent angles and acts only when they agree. The first angle is time: the Aroon Oscillator measures how recently price set its highest high versus its lowest low. The second angle is participation: Chaikin Money Flow measures whether closes land in the upper or lower part of each bar's range, weighted by volume. A trade idea is registered only when the Aroon Oscillator and Chaikin Money Flow both point the same way, and the Aroon flip and the money flow agreement happen close together in time. Each confirmed idea is paired with an ATR-based stop and three R-multiple targets, tracked live on the chart, in a dashboard and in alerts.

[b]● Overview[/b]
The script runs in its own pane. The pane shows the Aroon Oscillator as a line, Chaikin Money Flow as columns, and a zero line. The trade levels (stop, entry, three targets), the optional confluence candles and the optional dashboard are drawn on the price chart so that everything can be read in one place.
The indicator is a single pane tool that does not place orders and does not run a backtest. It marks where its own rules would have entered, where the stop sits and where each target sits, and it records whether those levels were reached afterwards.

[b]✨ Originality and Utility[/b]
Most Aroon-based and money-flow-based tools are used on their own. The Aroon Oscillator is a pure time statistic and ignores volume completely. Chaikin Money Flow is a pure volume-weighted close-location statistic and ignores how long a trend has been in place. Each one alone has a familiar weakness: Aroon lags after price has already moved, and money flow alone can stay positive or negative without a clear trend change.
This script adds three things on top of simply plotting both indicators:
[list]
[*]An agreement rule: both readings must be on the same side at the same time, and money flow must clear a buffer around zero rather than merely touching the zero line.
[*]A timing rule: the agreement must begin within a limited number of bars after the Aroon Oscillator crosses zero, so an old Aroon trend that money flow later joins by chance does not produce a late entry.
[*]A self-measured confirmation window: with Auto Confirm on, the allowed gap between the Aroon flip and the money flow agreement is measured from the chart's own history instead of being a fixed number the user must guess.
[/list]
The result is a two-condition filter with a clear, explainable reason for every signal, plus a ready trade frame (stop, three targets, live hit tracking, R-multiple result) so that the idea can be judged against defined risk rather than a bare arrow.

[b]✨ Mashup Justification[/b]
The two components were chosen because they answer different questions from different data. Aroon uses only the high and low series and counts bars. Chaikin Money Flow uses close, high, low and volume and measures pressure. They do not share inputs in the same way two price-based oscillators would, so agreement between them carries more information than agreement between, for example, two moving average variants.
The combination is also not arbitrary in how it is wired. The Aroon flip is treated as the timing event, because it marks the moment a new high or new low has become the more recent extreme. Money flow is treated as the permission layer, because it says whether volume-weighted closes support that direction. The confirmation window exists precisely because these two readings rarely turn on the same bar, and the script measures how far apart they usually turn.

[b]🔬 Methodology and Concepts[/b]

[b]• Aroon Oscillator[/b]
Aroon Up is 100 times (length minus the number of bars since the highest high in the window) divided by length. Aroon Down uses the lowest low the same way. The window holds length plus one bars, so a high set on the current bar reads 100 and a high set exactly length bars ago reads 0. The Aroon Oscillator is Aroon Up minus Aroon Down and is bounded between minus 100 and plus 100.
A positive value means the highest high in the window came more recently than the lowest low. A negative value means the opposite. The indicator was created by Tushar Chande in 1995, and a default length of 14 is used here, which matches the TradingView default. No reading appears until the length plus one bars exist.

[b]• Chaikin Money Flow[/b]
For each bar the script computes the money flow multiplier as (2 x close minus high minus low) divided by (high minus low). This equals the standard (close minus low) minus (high minus close), divided by the range. Multiplying by volume gives the money flow volume of the bar. Chaikin Money Flow is the sum of money flow volume over the chosen length divided by the sum of volume over the same length, so it is bounded between minus 1 and plus 1.
Values above zero point to buying pressure and values below zero to selling pressure. The method comes from Marc Chaikin. The common lengths are 20 or 21 bars, and 20 is the default here. Bars where the high equals the low have an undefined multiplier, so the script counts them as zero money flow and also leaves their volume out of the denominator. If the whole window holds no volume, money flow is undefined, no signal can fire and the dashboard says so.

[b]• Flow Buffer[/b]
Instead of reading money flow against the zero line alone, a long requires money flow above plus the buffer and a short requires it below minus the buffer. The default buffer is 0.05, which follows the commonly used plus and minus 0.05 thresholds that reduce false zero-line crosses. Setting it to 0 returns to the zero line.

[b]• Agreement and the signal rule[/b]
Bullish agreement means the Aroon Oscillator is above zero and money flow is above the buffer. Bearish agreement means the Aroon Oscillator is below zero and money flow is below the negative buffer. A long idea is registered on the bar where bullish agreement newly begins, provided the Aroon Oscillator crossed above zero within the confirmation window. A short idea works the same way in the opposite direction. Only closed bars can register an idea.
This means three cases are filtered out: agreement that was already present on the previous bar, agreement that begins long after the last Aroon flip, and an Aroon flip that money flow never joins.

[b]• Confirmation window[/b]
The window is the number of bars that may pass between the Aroon zero cross and the start of agreement. With Auto Confirm on, the script records the gap every time an Aroon flip is followed by agreement within 20 bars. It keeps the latest 20 gaps and uses their median, kept between 1 and 20 bars. The median is used because a single unusual gap does not move it much. Until 5 gaps have been measured, the window is about a quarter of the CMF length, which gives 5 bars at the default of 20.
With Auto Confirm off, the Confirm Bars input is used directly. A value of 0 requires money flow to agree on the same bar the Aroon Oscillator crosses zero.

[b]• Smoothing options[/b]
Both the Aroon Oscillator and money flow can be smoothed before any rule reads them. The choices are EMA, RMA, WMA, HMA, KAMA and Kalman, with None as the default. KAMA adapts its speed to an efficiency ratio, which is net change divided by total movement over the length, so it slows down in noisy conditions and speeds up in directional ones. The Kalman option is a one-dimensional recursive estimator whose process noise scales as one divided by the length against a fixed measurement noise, so a longer length gives a steadier line. Smoothing makes the lines calmer but adds lag, and the first smoothed values can appear later than the raw ones.

[b]• Trade frame[/b]
The entry is the close of the signal bar. The stop distance is the ATR multiplied by the stop multiplier, which is 14 bars and 1.5 by default. The three targets sit at multiples of that stop distance, 1R, 2R and 3R by default. If the target multiples are entered out of order, they are sorted from nearest to farthest and the dashboard shows a warning.
After the signal bar, a target counts as reached when the bar's high (for longs) or low (for shorts) touches it. The stop counts as hit when a bar closes beyond it, which means a brief wick through the stop level does not end the trade. Reaching the third target closes the trade. A new signal replaces any open trade, and that replacement is reported as a close followed by a new entry.

[b]• Optional filters[/b]
[list]
[*]HTF Confirm: a long needs the higher timeframe Aroon Oscillator above zero and a short needs it below zero. The higher timeframe value is taken from the last completed higher timeframe bar only. A higher timeframe lower than the chart timeframe is skipped and flagged on the dashboard.
[*]Trend Strength: a signal needs the previous bar's ADX to be at or above the minimum, 20 by default, using the chosen ADX length.
[/list]

[b]🎨 Visual Guide[/b]
[list]
[*]The thick line in the pane is the Aroon Oscillator. It is teal while at or above zero and red while below zero, using the Bull and Bear colors.
[*]The columns in the pane are Chaikin Money Flow multiplied by 100, so they read in percent. Teal columns are at or above zero and red columns are below zero, both semi-transparent.
[*]The dashed grey horizontal line is the zero line of the pane.
[*]With Candles enabled, the whole price candle is colored by the confluence state: teal when the Aroon Oscillator and money flow agree upward, red when they agree downward, and grey when they do not agree. These candles are drawn over the normal chart candles.
[*]When a signal registers, the price chart receives a solid red thick line for the stop, a dashed blue line for the entry and three dashed teal lines for the targets. The target lines get progressively more opaque from TP1 to TP3.
[*]Each line carries a label at its right end. The labels show the stop, the entry and TP1 to TP3 with their prices. If two levels round to the same price, they share one label with combined names.
[*]When a level is reached, its label changes to show that it was hit together with the percentage distance from the entry. The stop label shows the percentage at the closing price.
[*]Lines extend ten bars past the latest bar while a trade is open, and stop at ten bars past the bar where the trade closed.
[/list]

[b]• Dashboard[/b]
The dashboard has a header with the short name, the symbol and the timeframe, followed by rows with these meanings:
[list]
[*]Lock: shows whether Lock Signal is active.
[*]Bias: Bull, Bear or Neutral from the sign of the Aroon Oscillator.
[*]Aroon Up and Aroon Down: ten-segment progress bars with a percentage. They turn teal at 66 percent and above, amber from 33 to 66 percent and red below 33 percent. These two rows show raw values even when smoothing is on.
[*]Aroon Osc and CMF: the current numeric values.
[*]Money Flow: Buying, Selling or Neutral against the flow buffer.
[*]Confirm Bars: the window in use, marked Auto or Manual.
[*]Trade: Flat, or Long or Short with the state Open, Target 1, Target 2, Target 3 or Stopped.
[*]Entry, Stop, TP1, TP2, TP3 and ATR: the prices of the current trade, with a mark after a level that was reached.
[*]Open R: the open trade result at the current close, in multiples of the stop distance.
[*]HTF, ADX Prev and Smoothing: shown only while those features are on. The HTF value is green when the higher timeframe agrees with the current bias.
[*]Volume and Targets: amber warning rows that appear when no volume exists in the window or when the target multiples were reordered.
[/list]
With the dashboard switched off, only the active warning rows remain visible. The dashboard can be drawn on the price chart or kept inside the pane, and it can be placed in any of the four corners.

[b]📖 How to Use[/b]
[list=1]
[*]Add the indicator and leave the defaults to start. The pane will show the Aroon Oscillator line and the money flow columns.
[*]Read the line and the columns together. Both teal means upward agreement, both red means downward agreement. When one is teal and the other red, the two readings disagree and no new idea will form.
[*]Wait for a confirmed idea. A long idea appears on a closed bar when agreement turns up soon after the Aroon Oscillator crossed above zero. A short idea is the mirror image.
[*]Use the drawn levels as a defined risk frame. The stop is set from volatility, and the targets show how far price must travel for 1R, 2R and 3R.
[*]Watch the Trade and Open R rows to see how the current idea is developing, and watch the label changes to see which levels were reached.
[*]If you want fewer ideas, add HTF Confirm or Trend Strength, enlarge the Flow Buffer or apply smoothing. If you want more ideas, reduce the buffer or widen the Confirm Bars value with Auto Confirm off.
[*]Check results on the symbols and timeframes you trade before relying on any setting, and size positions according to your own risk limits.
[/list]
The indicator works on standard chart types only. On Renko, Kagi, Line break, Point and figure, Range or Heikin Ashi charts, it stops with an error message, because those chart types produce unrealistic results for signal logic.

[b]⚙️ Inputs and Settings[/b]
[b]• Core[/b]
[list]
[*]Aroon Length: the window for the highest high and lowest low. Shorter values react faster and flip more often, longer values are steadier.
[*]CMF Length: the number of bars summed for money flow. It also sets the starting confirmation window.
[*]Flow Buffer: how far money flow must be from zero to count as agreement.
[*]Auto Confirm: measures the confirmation window from the chart's own history.
[*]Confirm Bars: the manual window, used only while Auto Confirm is off.
[/list]
[b]• Filters[/b]
[list]
[*]HTF Confirm and HTF: require the higher timeframe Aroon Oscillator to agree.
[*]Trend Strength, ADX Length and ADX Min: require a minimum ADX on the previous bar.
[*]Smoothing and Smooth Length: choose a smoothing method and its length for both oscillators.
[/list]
[b]• Trade Tools[/b]
[list]
[*]Lock Signal: freezes the current trade and blocks new signals on the live bar.
[*]ATR Length and SL ATR x: set the stop distance.
[*]TP1 R, TP2 R and TP3 R: set the target distances as multiples of the stop distance.
[/list]
[b]• Visuals, Dashboard and Colors[/b]
[list]
[*]Switches for the trade levels, the confluence candles, the Aroon line, the money flow columns and the zero line.
[*]Dashboard visibility, corner position and whether it is drawn on the price chart.
[*]Every color used by the lines, columns, candles, levels, labels and dashboard can be changed.
[/list]
[b]• Alerts[/b]
Six alert conditions are available: Buy Signal, Sell Signal, Close Long, Close Short, Partial Close Long and Partial Close Short. Alert messages are also sent as structured text containing the action word, the symbol, the timeframe, the direction, and for entries the entry, stop, three targets and the current Aroon and money flow values. The action words for long, short, close and partial close can be edited in the inputs. Entry and stop alerts fire once per closed bar, and target alerts fire once per bar.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
[b]• Aroon as a time-based order statistic[/b]
Aroon discards price magnitude and keeps only the position in time of the window maximum and minimum. This is a rank-based idea: it asks where in a window of recent observations the extreme value sits, not how large it is. Because it uses only the ordering of values, it is insensitive to the scale of the instrument and to the size of any single spike. The oscillator then compares the recency of the maximum against the recency of the minimum, which gives a bounded measure of whether the window's extremes are being set up or down.
The statistical consequence is that Aroon responds to the sequence of new extremes, which is the defining feature of a trending series, and tends to drift toward zero in a range where highs and lows alternate. Its weakness follows from the same property: an extreme can only be recognised after it has formed and remains in the window, so the reading lags.

[b]• Chaikin Money Flow as a volume-weighted average of close location[/b]
The money flow multiplier is the close location value, which places the close inside the bar's range on a scale from minus 1 to plus 1. Weighting it by volume and dividing by total volume turns it into a volume-weighted average of close location over the window. This is a weighted mean, so the result is bounded by construction and is comparable across instruments.
The measure assumes that a close near the top of the range reflects buying pressure and a close near the bottom reflects selling pressure, and it gives more weight to bars with more participation. It does not see gaps between bars or activity inside the bar beyond the high, low and close, which is a recognised limitation of the method.

[b]• Why combine a rank statistic with a weighted mean[/b]
The two measures are built from different information. One uses the ordering of highs and lows over time. The other uses a volume-weighted average of closing position. Requiring both to agree is a simple form of evidence combination: a condition that two partly independent measurements both support is less likely to come from noise in a single measurement than a condition supported by one measurement alone. The confirmation window addresses the fact that a time-based statistic and a pressure-based statistic reach their turning points at different speeds.
The median used to estimate the window is a robust location estimate. Unlike an average, it is not pulled far by one unusually long gap, which suits a small, changing sample of at most 20 observations.

[b]• Smoothing filters[/b]
The optional smoothers belong to the family of recursive and weighted filters. EMA and RMA apply exponentially declining weights with different smoothing constants. WMA applies linearly declining weights. HMA combines weighted averages to reduce lag. KAMA scales its smoothing constant by an efficiency ratio, which compares net displacement with total path length, so its responsiveness depends on how directional the recent data is. The Kalman option is a scalar recursive estimator that blends the previous estimate with the new observation using a gain computed from the estimate's uncertainty. All of them trade lag against noise, and none removes lag entirely.

[b]• Volatility-scaled risk and R-multiples[/b]
The stop distance is a multiple of the Average True Range, a volatility measure that accounts for gaps between bars. Scaling the stop to volatility makes the distance adapt to current conditions instead of staying fixed in price terms. Targets are expressed as multiples of that distance, called R-multiples, so every outcome can be compared with the risk taken on that idea. The Open R row applies the same unit to the open result.

[b]● Limitations and Live-Bar Behavior[/b]
[list]
[*]Both Aroon and Chaikin Money Flow lag, because they describe what price has already done. Ideas can arrive after a move has started, and a reversal can follow an idea.
[*]On the latest, unclosed bar, the Aroon line, the money flow columns, the dashboard values and the target-touch tracking update with each tick. New ideas and stop hits are decided only when a bar closes, but a target touch can be recorded intrabar and may be seen on a live bar. Reload the chart to see the confirmed history.
[*]Chaikin Money Flow depends on volume. On feeds that report tick volume, which counts trades and not units traded, the readings reflect trade activity and not size. Symbols with no volume produce no ideas.
[*]The higher timeframe filter reads the last completed higher timeframe bar, so it cannot use unfinished data, but it also reacts to a higher timeframe change only after that bar closes.
[*]Smoothing, a larger flow buffer and the optional filters reduce the number of ideas and add delay.
[*]Auto Confirm learns from the loaded chart history, so its window can differ between symbols, timeframes and the amount of history loaded.
[*]The drawn levels illustrate a defined risk frame. They do not account for slippage, spreads, commissions or gaps through the stop.
[/list]

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Aroon Money Flow Confluence [MarkitTick]", overlay = false)

// ── INPUTS ──────────────────────────────────────────
var string GRP_CORE = "⚙️ Core"
var string GRP_FILT = "🕯️ Filters"
var string GRP_TRADE = "📐 Trade Tools"
var string GRP_VIS = "🎨 Visuals"
var string GRP_DASH = "📊 Dashboard"
var string GRP_WH = "🔔 Alerts"
var string GRP_COL = "🌈 Colors"
i_aroonLen = input.int(14, "Aroon Length", minval = 2, maxval = 5000, group = GRP_CORE, tooltip = "Window for the Aroon highs and lows. No Aroon reading until this many bars plus one exist.")
i_cmfLen = input.int(20, "CMF Length", minval = 2, maxval = 5000, group = GRP_CORE, tooltip = "Bars summed for Chaikin Money Flow. No reading until this many bars exist.")
i_flowBuf = input.float(0.05, "Flow Buffer", minval = 0.0, maxval = 0.5, step = 0.01, group = GRP_CORE, tooltip = "Chaikin Money Flow must be above +buffer for a long and below -buffer for a short. 0 uses the zero line.")
i_autoConfirm = input.bool(true, "Auto Confirm", group = GRP_CORE, tooltip = "On: the confirm window is measured on the chart as the middle value of the last 20 gaps between an Aroon flip and Chaikin Money Flow agreeing, kept between 1 and 20 bars. Until 5 gaps are measured it uses about a quarter of CMF Length. The Confirm Bars number below is ignored. Off: the Confirm Bars number is used.")
i_confirmBars = input.int(0, "Confirm Bars", minval = 0, maxval = 20, group = GRP_CORE, tooltip = "Used only while Auto Confirm is off. 0: money flow must already agree on the bar Aroon flips. N: the Aroon flip may come up to N bars before money flow agrees.")
i_useHtf = input.bool(false, "HTF Confirm", group = GRP_FILT, tooltip = "A long needs the higher-timeframe Aroon Oscillator above zero, a short needs it below zero. Reads confirmed higher-timeframe bars only.")
i_htf = input.timeframe("60", "HTF", group = GRP_FILT, tooltip = "Not lower than the chart timeframe. A lower one is skipped and shown on the dashboard.")
i_useAdx = input.bool(false, "Trend Strength", group = GRP_FILT, tooltip = "Signal needs the previous bar's ADX at or above the minimum.")
i_adxLen = input.int(14, "ADX Length", minval = 1, maxval = 5000, group = GRP_FILT, tooltip = "Length used for the directional movement and the ADX that Trend Strength reads.")
i_adxMin = input.float(20.0, "ADX Min", minval = 0.0, maxval = 100.0, group = GRP_FILT, tooltip = "Minimum ADX the previous bar must reach for a signal while Trend Strength is on.")
i_smoothType = input.string("None", "Smoothing", options = ["None", "EMA", "RMA", "WMA", "HMA", "KAMA", "Kalman"], group = GRP_FILT, tooltip = "Smooths the Aroon Oscillator and Chaikin Money Flow before any signal is derived from them. The first smoothed values can come later than the raw ones.")
i_smoothLen = input.int(10, "Smooth Length", minval = 2, maxval = 5000, group = GRP_FILT, tooltip = "Length of the smoothing method chosen above. It has no effect while Smoothing is None.")
i_lockSignal = input.bool(false, "Lock Signal", group = GRP_TRADE, tooltip = "Freeze current signal · block new ones")
i_atrLen = input.int(14, "ATR Length", minval = 1, maxval = 5000, group = GRP_TRADE, tooltip = "Bars in the ATR that sets the stop distance. No trade is armed until the ATR has a value.")
i_slMult = input.float(1.5, "SL ATR x", minval = 0.1, step = 0.1, group = GRP_TRADE, tooltip = "Stop distance in ATR from the entry, which is the close of the signal bar.")
i_tp1R = input.float(1.0, "TP1 R", minval = 0.1, step = 0.1, group = GRP_TRADE, tooltip = "Target distance as a multiple of the stop distance. Targets set out of order are sorted nearest to farthest.")
i_tp2R = input.float(2.0, "TP2 R", minval = 0.1, step = 0.1, group = GRP_TRADE, tooltip = "Second target distance as a multiple of the stop distance.")
i_tp3R = input.float(3.0, "TP3 R", minval = 0.1, step = 0.1, group = GRP_TRADE, tooltip = "Third and final target distance as a multiple of the stop distance. Reaching it closes the trade.")
i_showLevels = input.bool(true, "Trade Levels", group = GRP_VIS, tooltip = "Draws the stop, entry and target lines and labels for the current trade. Hit tracking and alerts run with it off.")
i_showCandles = input.bool(false, "Candles", group = GRP_VIS, tooltip = "Colors the whole candle by the confluence state: Bull when Aroon and Money Flow agree up, Bear when they agree down, Neutral otherwise. Drawn over the chart candles, which stay underneath.")
i_showAroon = input.bool(true, "Aroon Osc", group = GRP_VIS, tooltip = "Shows the Aroon Oscillator line.")
i_showCmf = input.bool(true, "CMF", group = GRP_VIS, tooltip = "Plotted as percent: Chaikin Money Flow x 100.")
i_showZero = input.bool(true, "Zero Line", group = GRP_VIS, tooltip = "Shows the zero line of the pane.")
i_showDash = input.bool(true, "Show Dashboard", group = GRP_DASH, tooltip = "Shows the dashboard. With it off, the table lists only the warnings that are active: a skipped higher timeframe, no volume, reordered targets.")
i_dashPos = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH, tooltip = "Corner of the chart where the dashboard is drawn.")
i_dashOnPrice = input.bool(true, "Show on Price Chart", group = GRP_DASH, tooltip = "On: the dashboard is drawn on the price chart. Off: it stays in the indicator pane.")
i_actionLong = input.string("long", "↑ Long Action", group = GRP_WH, tooltip = "Action word sent in the alert payload when a long entry is signalled.")
i_actionShort = input.string("short", "↓ Short Action", group = GRP_WH, tooltip = "Action word sent in the alert payload when a short entry is signalled.")
i_actionCloseLong = input.string("closelong", "✕ Close Long Action", group = GRP_WH, tooltip = "Action word sent when a long trade closes: final target, stop, or replacement by a new signal.")
i_actionCloseShort = input.string("closeshort", "✕ Close Short Action", group = GRP_WH, tooltip = "Action word sent when a short trade closes: final target, stop, or replacement by a new signal.")
i_actionPartLong = input.string("partialcloselong", "✕ Partial Close Long Action", group = GRP_WH, tooltip = "Action word sent when a long trade reaches TP1 or TP2, which leaves the trade open.")
i_actionPartShort = input.string("partialcloseshort", "✕ Partial Close Short Action", group = GRP_WH, tooltip = "Action word sent when a short trade reaches TP1 or TP2, which leaves the trade open.")
c_sup = input.color(#26a69a, "Bull", group = GRP_COL, tooltip = "Bullish colour: Aroon line above zero, Bull candles and bullish dashboard values.")
c_res = input.color(#ef5350, "Bear", group = GRP_COL, tooltip = "Bearish colour: Aroon line below zero, Bear candles, bearish dashboard values and the active Lock value.")
c_candleNeu = input.color(color.new(#787b86, 0), "Candle Neutral", group = GRP_COL, tooltip = "Candle colour when Aroon and Money Flow do not agree.")
c_cmfUp = input.color(color.new(#26a69a, 50), "CMF Up", group = GRP_COL, tooltip = "Money flow columns at or above zero.")
c_cmfDn = input.color(color.new(#ef5350, 50), "CMF Down", group = GRP_COL, tooltip = "Money flow columns below zero.")
c_zero = input.color(color.new(#787b86, 50), "Zero Line", group = GRP_COL, tooltip = "Zero line of the pane.")
c_sl = input.color(#ef5350, "SL", group = GRP_COL, tooltip = "Stop line. The stop label uses the same colour at full opacity.")
c_entry = input.color(#2196f3, "Entry", group = GRP_COL, tooltip = "Entry line. The entry label uses the same colour at full opacity.")
c_tp1 = input.color(color.new(#26a69a, 40), "TP1", group = GRP_COL, tooltip = "TP1 line. The TP1 label uses the same colour at full opacity.")
c_tp2 = input.color(color.new(#26a69a, 20), "TP2", group = GRP_COL, tooltip = "TP2 line. The TP2 label uses the same colour at full opacity.")
c_tp3 = input.color(color.new(#26a69a, 0), "TP3", group = GRP_COL, tooltip = "TP3 line. The TP3 label uses the same colour at full opacity.")
c_lblTxt = input.color(#ffffff, "Label Text", group = GRP_COL, tooltip = "Text colour of the trade level labels.")
c_barHi = input.color(#26a69a, "Bar High", group = GRP_COL, tooltip = "Dashboard progress bars at 66% and above, and a filter row that passes.")
c_barMid = input.color(#f9a825, "Bar Mid", group = GRP_COL, tooltip = "Dashboard progress bars from 33% up to 66%.")
c_barLo = input.color(#ef5350, "Bar Low", group = GRP_COL, tooltip = "Dashboard progress bars below 33%, and a filter row that fails.")
c_warn = input.color(color.new(#f9a825, 80), "Warning Fill", group = GRP_COL, tooltip = "Fill of dashboard rows that warn: a skipped higher timeframe, no volume, reordered targets.")
c_dashHdr = input.color(color.new(#3a2a6d, 55), "Dash Header", group = GRP_COL, tooltip = "Fill of the dashboard header row.")
c_dashBg = input.color(color.new(#0a0f1a, 10), "Dash Background", group = GRP_COL, tooltip = "Dashboard row background. The alternate rows use a faded copy of it.")
c_dashTxt = input.color(#ffffff, "Dash Text", group = GRP_COL, tooltip = "Dashboard text colour. The labels use a faded copy of it.")

// ── CORE LOGIC ──────────────────────────────────────────
if not chart.is_standard
    runtime.error("This indicator does not run on non-standard chart types (Renko, Kagi, Line break, Point & figure, Range, Heikin Ashi). Switch the chart to a standard type.")

f_esc(string s) =>
    str.replace_all(str.replace_all(s, "\\", "\\\\"), "\"", "\\\"")

f_tf(string tf) =>
    string _digits = str.replace_all(str.replace_all(str.replace_all(str.replace_all(str.replace_all(tf, "D", ""), "W", ""), "M", ""), "S", ""), "T", "")
    int _n = _digits == "" ? 1 : int(str.tonumber(_digits))
    string _out = ""
    if str.endswith(tf, "D")
        _out := str.tostring(_n) + "D"
    else if str.endswith(tf, "W")
        _out := str.tostring(_n) + "W"
    else if str.endswith(tf, "M")
        _out := str.tostring(_n) + "M"
    else if str.endswith(tf, "S")
        _out := str.tostring(_n) + "s"
    else if str.endswith(tf, "T")
        _out := str.tostring(_n) + "T"
    else if _n % 1440 == 0
        _out := str.tostring(int(_n / 1440)) + "D"
    else if _n % 60 == 0
        _out := str.tostring(int(_n / 60)) + "H"
    else
        _out := str.tostring(_n) + "m"
    _out

f_pctTxt(float lvl, float entry, bool isLong) =>
    float _p = (isLong ? lvl - entry : entry - lvl) / entry * 100
    (_p >= 0 ? "+" : "") + str.tostring(_p, "#.00") + "%"

f_kama(float src, simple int len) =>
    float _chg = math.abs(src - src[len])
    float _vol = math.sum(math.abs(ta.change(src)), len)
    float _er = _vol > 0 ? _chg / _vol : 0.0
    float _a = _er * (2.0 / 3.0 - 2.0 / 31.0) + 2.0 / 31.0
    float _seed = ta.sma(src, len)
    var float _k = float(na)
    _k := na(_k) ? _seed : _k + _a * _a * (src - _k)
    _k

f_kalman(float src, simple int len) =>
    var float _est = float(na)
    var float _err = 1.0
    float _q = 1.0 / len
    float _r = 1.0
    _est := na(_est) ? src : _est
    float _predErr = _err + _q
    float _gain = _predErr / (_predErr + _r)
    _est := _est + _gain * (src - _est)
    _err := (1 - _gain) * _predErr
    _est

f_smooth(float src, simple string smoothMethod, simple int len) =>
    float _ema = ta.ema(src, smoothMethod == "EMA" ? len : 2)
    float _rma = ta.rma(src, smoothMethod == "RMA" ? len : 2)
    float _wma = ta.wma(src, smoothMethod == "WMA" ? len : 2)
    float _hma = ta.hma(src, smoothMethod == "HMA" ? len : 2)
    float _kama = f_kama(src, smoothMethod == "KAMA" ? len : 2)
    float _kal = f_kalman(src, smoothMethod == "Kalman" ? len : 2)
    switch smoothMethod
        "EMA" => _ema
        "RMA" => _rma
        "WMA" => _wma
        "HMA" => _hma
        "KAMA" => _kama
        "Kalman" => _kal
        => src

f_aroonUp(int len) =>
    int _hb = ta.highestbars(high, len + 1)
    bar_index >= len ? 100.0 * (len + _hb) / len : na

f_aroonDn(int len) =>
    int _lb = ta.lowestbars(low, len + 1)
    bar_index >= len ? 100.0 * (len + _lb) / len : na

f_aroonOsc(int len) =>
    f_aroonUp(len) - f_aroonDn(len)

f_cmf(int len) =>
    float _hl = high - low
    float _mfv = _hl > 0 ? (2.0 * close - high - low) / _hl * volume : 0.0
    float _vv = _hl > 0 ? volume : 0.0
    float _sMfv = math.sum(_mfv, len)
    float _sV = math.sum(_vv, len)
    bar_index >= len - 1 and _sV > 0 ? _sMfv / _sV : na

var int tradeDir = 0
var float tEntry = float(na)
var float tSl = float(na)
var float tTp1 = float(na)
var float tTp2 = float(na)
var float tTp3 = float(na)
var int sigBar = int(na)
var int closeBar = int(na)
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool slHit = false
var int ld1 = 1
var int ld2 = 2
var int ld3 = 3
var string namesE = "Entry"
var string names1 = "TP1"
var string names2 = "TP2"
var string names3 = "TP3"
var line slLine = na
var line entryLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na
var label slLbl = na
var label entryLbl = na
var label tp1Lbl = na
var label tp2Lbl = na
var label tp3Lbl = na
var array<float> lagSamples = array.new_float()
var int pendBullBar = int(na)
var int pendBearBar = int(na)

f_deleteLevels() =>
    line.delete(slLine), line.delete(entryLine)
    line.delete(tp1Line), line.delete(tp2Line), line.delete(tp3Line)
    label.delete(slLbl), label.delete(entryLbl)
    label.delete(tp1Lbl), label.delete(tp2Lbl), label.delete(tp3Lbl)

f_ldLbl(int ld) =>
    ld == 0 ? entryLbl : ld == 1 ? tp1Lbl : ld == 2 ? tp2Lbl : tp3Lbl

f_ldNames(int ld) =>
    ld == 0 ? namesE : ld == 1 ? names1 : ld == 2 ? names2 : names3

float aroonUp = f_aroonUp(i_aroonLen)
float aroonDn = f_aroonDn(i_aroonLen)
float aroonRaw = aroonUp - aroonDn
float cmfRaw = f_cmf(i_cmfLen)
float aroonOsc = f_smooth(aroonRaw, i_smoothType, i_smoothLen)
float cmf = f_smooth(cmfRaw, i_smoothType, i_smoothLen)
[_diP, _diM, adxVal] = ta.dmi(i_useAdx ? i_adxLen : 1, i_useAdx ? i_adxLen : 1)
float atrVal = ta.atr(i_atrLen)
var string STD_TICKER = chart.is_standard ? syminfo.tickerid : ticker.standard(syminfo.tickerid)
var bool htfValid = timeframe.in_seconds(i_htf) >= timeframe.in_seconds()
bool htfActive = i_useHtf and htfValid
float htfOsc = na
if htfActive
    htfOsc := request.security(STD_TICKER, i_htf, f_aroonOsc(i_aroonLen)[1], lookahead = barmerge.lookahead_on)
bool htfOkLong = not htfActive or htfOsc > 0
bool htfOkShort = not htfActive or htfOsc < 0
float adxPrev = adxVal[1]
bool adxOk = not i_useAdx or adxPrev >= i_adxMin
bool aroonBullX = ta.crossover(aroonOsc, 0.0)
bool aroonBearX = ta.crossunder(aroonOsc, 0.0)
int sinceBull = ta.barssince(aroonBullX)
int sinceBear = ta.barssince(aroonBearX)
bool agreeBull = aroonOsc > 0 and cmf > i_flowBuf
bool agreeBear = aroonOsc < 0 and cmf < -i_flowBuf
if barstate.isconfirmed
    if aroonBullX
        pendBullBar := bar_index
        pendBearBar := int(na)
    if aroonBearX
        pendBearBar := bar_index
        pendBullBar := int(na)
    if not na(pendBullBar) and bar_index - pendBullBar > 20
        pendBullBar := int(na)
    if not na(pendBearBar) and bar_index - pendBearBar > 20
        pendBearBar := int(na)
    if not na(pendBullBar) and agreeBull
        array.push(lagSamples, bar_index - pendBullBar)
        pendBullBar := int(na)
    if not na(pendBearBar) and agreeBear
        array.push(lagSamples, bar_index - pendBearBar)
        pendBearBar := int(na)
    if array.size(lagSamples) > 20
        array.shift(lagSamples)
int confirmQuarter = math.max(1, math.min(20, math.round((i_cmfLen - 1) / 4.0)))
int confirmMeasured = array.size(lagSamples) >= 5 ? math.max(1, math.min(20, math.round(array.median(lagSamples)))) : confirmQuarter
int confirmEff = i_autoConfirm ? confirmMeasured : i_confirmBars
bool rawLong = agreeBull and not agreeBull[1] and sinceBull <= confirmEff
bool rawShort = agreeBear and not agreeBear[1] and sinceBear <= confirmEff
bool sigLong = rawLong and htfOkLong and adxOk and barstate.isconfirmed
bool sigShort = rawShort and htfOkShort and adxOk and barstate.isconfirmed
float rLo = math.min(i_tp1R, math.min(i_tp2R, i_tp3R))
float rHi = math.max(i_tp1R, math.max(i_tp2R, i_tp3R))
float rMid = math.max(math.min(i_tp1R, i_tp2R), math.min(math.max(i_tp1R, i_tp2R), i_tp3R))
float entryPx = close
float riskDist = atrVal * i_slMult
float slLong = entryPx - riskDist
float tp1L = entryPx + riskDist * rLo
float tp2L = entryPx + riskDist * rMid
float tp3L = entryPx + riskDist * rHi
float slShort = entryPx + riskDist
float tp1S = entryPx - riskDist * rLo
float tp2S = entryPx - riskDist * rMid
float tp3S = entryPx - riskDist * rHi
bool okLong = riskDist > syminfo.mintick and slLong > 0
bool okShort = riskDist > syminfo.mintick and tp3S > 0
bool regLong = sigLong and okLong
bool regShort = sigShort and okShort

bool isLongT = tradeDir == 1
bool liveT = tradeDir != 0 and bar_index > sigBar
bool tp1Cross = liveT and (isLongT ? high >= tTp1 : low <= tTp1)
bool tp2Cross = liveT and (isLongT ? high >= tTp2 : low <= tTp2)
bool tp3Cross = liveT and (isLongT ? high >= tTp3 : low <= tTp3)
bool slCross = liveT and barstate.isconfirmed and (isLongT ? close < tSl : close > tSl)
bool tp1New = false
bool tp2New = false
bool tp3New = false
bool slNew = false
if tp1Cross and not tp1Hit and not slHit
    tp1Hit := true
    tp1New := true
if tp2Cross and not tp2Hit and not slHit
    tp2Hit := true
    tp2New := true
if tp3Cross and not tp3Hit and not slHit
    tp3Hit := true
    tp3New := true
if slCross and not slHit and not tp3Hit
    slHit := true
    slNew := true
if tp1New and not na(f_ldLbl(ld1))
    label.set_text(f_ldLbl(ld1), f_ldNames(ld1) + " ✓ HIT " + f_pctTxt(tTp1, tEntry, isLongT))
if tp2New and not na(f_ldLbl(ld2))
    label.set_text(f_ldLbl(ld2), f_ldNames(ld2) + " ✓ HIT " + f_pctTxt(tTp2, tEntry, isLongT))
if tp3New and not na(f_ldLbl(ld3))
    label.set_text(f_ldLbl(ld3), f_ldNames(ld3) + " ✓ HIT " + f_pctTxt(tTp3, tEntry, isLongT))
if slNew and not na(slLbl)
    label.set_text(slLbl, "SL ✓ HIT " + f_pctTxt(close, tEntry, isLongT))

int pDir = tradeDir
float pSl = tSl
float pTp1 = tTp1
float pTp2 = tTp2
float pTp3 = tTp3
bool _locked = i_lockSignal and barstate.islast
bool evLong = regLong and not _locked
bool evShort = regShort and not _locked
bool evNew = evLong or evShort
bool openNow = tradeDir != 0 and not slHit and not tp3Hit
bool closeOld = evNew and openNow
bool sameDir = (evLong and tradeDir == 1) or (evShort and tradeDir == -1)
if evNew
    f_deleteLevels()
    slLine := na
    entryLine := na
    tp1Line := na
    tp2Line := na
    tp3Line := na
    slLbl := na
    entryLbl := na
    tp1Lbl := na
    tp2Lbl := na
    tp3Lbl := na
    float nSl = evLong ? slLong : slShort
    float nTp1 = evLong ? tp1L : tp1S
    float nTp2 = evLong ? tp2L : tp2S
    float nTp3 = evLong ? tp3L : tp3S
    tradeDir := evLong ? 1 : -1
    tEntry := entryPx
    tSl := nSl
    tTp1 := nTp1
    tTp2 := nTp2
    tTp3 := nTp3
    sigBar := bar_index
    closeBar := int(na)
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit := false
    string kE = str.tostring(entryPx, format.mintick)
    string kT1 = str.tostring(nTp1, format.mintick)
    string kT2 = str.tostring(nTp2, format.mintick)
    string kT3 = str.tostring(nTp3, format.mintick)
    bool m1 = kT1 == kE
    bool m2e = kT2 == kE
    bool m2a = not m2e and kT2 == kT1
    bool m3e = kT3 == kE
    bool m3a = not m3e and kT3 == kT1
    bool m3b = not m3e and not m3a and kT3 == kT2
    ld1 := m1 ? 0 : 1
    ld2 := m2e ? 0 : m2a ? 1 : 2
    ld3 := m3e ? 0 : m3a ? 1 : m3b ? 2 : 3
    namesE := "Entry" + (m1 ? " / TP1" : "") + (m2e ? " / TP2" : "") + (m3e ? " / TP3" : "")
    names1 := "TP1" + (m2a ? " / TP2" : "") + (m3a ? " / TP3" : "")
    names2 := "TP2" + (m3b ? " / TP3" : "")
    names3 := "TP3"
    if i_showLevels
        slLine := line.new(bar_index, nSl, bar_index, nSl, color = c_sl, style = line.style_solid, width = 2, force_overlay = true)
        entryLine := line.new(bar_index, entryPx, bar_index, entryPx, color = c_entry, style = line.style_dashed, width = 1, force_overlay = true)
        tp1Line := line.new(bar_index, nTp1, bar_index, nTp1, color = c_tp1, style = line.style_dashed, width = 1, force_overlay = true)
        tp2Line := line.new(bar_index, nTp2, bar_index, nTp2, color = c_tp2, style = line.style_dashed, width = 1, force_overlay = true)
        tp3Line := line.new(bar_index, nTp3, bar_index, nTp3, color = c_tp3, style = line.style_dashed, width = 1, force_overlay = true)
        slLbl := label.new(bar_index, nSl, "✕ SL " + str.tostring(nSl, format.mintick), style = label.style_label_left, color = color.new(c_sl, 0), textcolor = c_lblTxt, size = size.small, force_overlay = true)
        entryLbl := label.new(bar_index, entryPx, "▶ " + namesE + " " + kE, style = label.style_label_left, color = color.new(c_entry, 0), textcolor = c_lblTxt, size = size.small, force_overlay = true)
        if not m1
            tp1Lbl := label.new(bar_index, nTp1, "◆ " + names1 + " " + kT1, style = label.style_label_left, color = color.new(c_tp1, 0), textcolor = c_lblTxt, size = size.small, force_overlay = true)
        if not m2e and not m2a
            tp2Lbl := label.new(bar_index, nTp2, "✦ " + names2 + " " + kT2, style = label.style_label_left, color = color.new(c_tp2, 0), textcolor = c_lblTxt, size = size.small, force_overlay = true)
        if not m3e and not m3a and not m3b
            tp3Lbl := label.new(bar_index, nTp3, "◆ " + names3 + " " + kT3, style = label.style_label_left, color = color.new(c_tp3, 0), textcolor = c_lblTxt, size = size.small, force_overlay = true)
bool tradeClosed = slHit or tp3Hit
if tradeDir != 0 and tradeClosed and na(closeBar)
    closeBar := bar_index
bool extUpdate = tradeClosed ? closeBar == bar_index : barstate.islast
if not na(slLine) and extUpdate
    int extX = tradeClosed ? closeBar + 10 : last_bar_index + 10
    line.set_x2(slLine, extX)
    line.set_x2(entryLine, extX)
    line.set_x2(tp1Line, extX)
    line.set_x2(tp2Line, extX)
    line.set_x2(tp3Line, extX)
    label.set_x(slLbl, extX)
    label.set_x(entryLbl, extX)
    if not na(tp1Lbl)
        label.set_x(tp1Lbl, extX)
    if not na(tp2Lbl)
        label.set_x(tp2Lbl, extX)
    if not na(tp3Lbl)
        label.set_x(tp3Lbl, extX)

// ── ALERTS ──────────────────────────────────────────
var string aLong = f_esc(i_actionLong)
var string aShort = f_esc(i_actionShort)
var string aCloseLong = f_esc(i_actionCloseLong)
var string aCloseShort = f_esc(i_actionCloseShort)
var string aPartLong = f_esc(i_actionPartLong)
var string aPartShort = f_esc(i_actionPartShort)
var string tkr = f_esc(syminfo.tickerid)
var string tfp = f_esc(timeframe.period)
string pSide = pDir == 1 ? "long" : "short"
string pClose = pDir == 1 ? aCloseLong : aCloseShort
string pPart = pDir == 1 ? aPartLong : aPartShort
bool evPartLong = pDir == 1 and (tp1New or tp2New)
bool evPartShort = pDir == -1 and (tp1New or tp2New)
bool evCloseLong = (closeOld and pDir == 1) or (pDir == 1 and (tp3New or slNew))
bool evCloseShort = (closeOld and pDir == -1) or (pDir == -1 and (tp3New or slNew))
if tp1New
    string _p1Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","tp":"1","price":"{4}","sl":"{5}"', pPart, tkr, tfp, pSide, str.tostring(pTp1, format.mintick), str.tostring(pSl, format.mintick))
    alert("{" + _p1Inner + "}", alert.freq_once_per_bar)
if tp2New
    string _p2Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","tp":"2","price":"{4}","sl":"{5}"', pPart, tkr, tfp, pSide, str.tostring(pTp2, format.mintick), str.tostring(pSl, format.mintick))
    alert("{" + _p2Inner + "}", alert.freq_once_per_bar)
if tp3New
    string _p3Inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","reason":"target","price":"{4}"', pClose, tkr, tfp, pSide, str.tostring(pTp3, format.mintick))
    alert("{" + _p3Inner + "}", alert.freq_once_per_bar)
if slNew and barstate.isconfirmed
    string _slInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","reason":"stop","price":"{4}"', pClose, tkr, tfp, pSide, str.tostring(close, format.mintick))
    alert("{" + _slInner + "}", alert.freq_once_per_bar_close)
if closeOld and barstate.isconfirmed
    string _coInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","reason":"{4}","price":"{5}"', pClose, tkr, tfp, pSide, sameDir ? "replaced" : "reverse", str.tostring(close, format.mintick))
    alert("{" + _coInner + "}", alert.freq_once_per_bar_close)
if evLong and barstate.isconfirmed
    string _lInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"long","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","aroon":"{8}","cmf":"{9}"', aLong, tkr, tfp, str.tostring(entryPx, format.mintick), str.tostring(slLong, format.mintick), str.tostring(tp1L, format.mintick), str.tostring(tp2L, format.mintick), str.tostring(tp3L, format.mintick), str.tostring(math.round(aroonOsc, 1)), str.tostring(math.round(cmf, 3)))
    alert("{" + _lInner + "}", alert.freq_once_per_bar_close)
if evShort and barstate.isconfirmed
    string _sInner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"short","entry":"{3}","sl":"{4}","tp1":"{5}","tp2":"{6}","tp3":"{7}","aroon":"{8}","cmf":"{9}"', aShort, tkr, tfp, str.tostring(entryPx, format.mintick), str.tostring(slShort, format.mintick), str.tostring(tp1S, format.mintick), str.tostring(tp2S, format.mintick), str.tostring(tp3S, format.mintick), str.tostring(math.round(aroonOsc, 1)), str.tostring(math.round(cmf, 3)))
    alert("{" + _sInner + "}", alert.freq_once_per_bar_close)
alertcondition(evLong and barstate.isconfirmed, "BUY Signal", "MarkitTick Aroon Money Flow Confluence — BUY Signal")
alertcondition(evShort and barstate.isconfirmed, "SELL Signal", "MarkitTick Aroon Money Flow Confluence — SELL Signal")
alertcondition(evCloseLong, "Close Long Signal", "MarkitTick Aroon Money Flow Confluence — Close Long")
alertcondition(evCloseShort, "Close Short Signal", "MarkitTick Aroon Money Flow Confluence — Close Short")
alertcondition(evPartLong, "Partial Close Long", "MarkitTick Aroon Money Flow Confluence — Partial Close Long")
alertcondition(evPartShort, "Partial Close Short", "MarkitTick Aroon Money Flow Confluence — Partial Close Short")

// ── VISUALS ──────────────────────────────────────────
plot(aroonOsc, "Aroon Osc", color = i_showAroon ? (aroonOsc >= 0 ? c_sup : c_res) : na, linewidth = 2)
plot(cmf * 100, "CMF %", style = plot.style_columns, color = i_showCmf ? (cmf >= 0 ? c_cmfUp : c_cmfDn) : na)
hline(0, "Zero", color = c_zero, linestyle = hline.style_dashed, display = i_showZero ? display.all : display.none)
color candleColor = i_showCandles and not na(aroonOsc) and not na(cmf) ? (agreeBull ? c_sup : agreeBear ? c_res : c_candleNeu) : na
plotcandle(open, high, low, close, title = "Confluence Candles", color = candleColor, wickcolor = candleColor, bordercolor = candleColor, force_overlay = true)

// ── DASHBOARD ──────────────────────────────────────────
f_bar(float val, float maxVal) =>
    int filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string bar = ""
    for i = 1 to 10
        bar += i <= filled ? "█" : "░"
    bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

f_barColor(float pct) =>
    pct >= 0.66 ? c_barHi : pct >= 0.33 ? c_barMid : c_barLo

f_dashPos(string p) =>
    switch p
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_row(table t, int r, string lbl, string val, color valCol, color bg, color lblCol, string tip) =>
    table.cell(t, 0, r, "  " + lbl, text_color = lblCol, text_halign = text.align_left, text_size = size.small, bgcolor = bg, tooltip = tip)
    table.cell(t, 1, r, val + "  ", text_color = valCol, text_halign = text.align_right, text_size = size.small, bgcolor = bg, tooltip = tip)

var table dash = i_dashOnPrice ? table.new(f_dashPos(i_dashPos), 2, 22, border_width = i_showDash ? 1 : 0, border_color = color.new(#2a3040, 40), frame_width = i_showDash ? 1 : 0, frame_color = color.new(#3a2a6d, 40), force_overlay = true) : table.new(f_dashPos(i_dashPos), 2, 22, border_width = i_showDash ? 1 : 0, border_color = color.new(#2a3040, 40), frame_width = i_showDash ? 1 : 0, frame_color = color.new(#3a2a6d, 40))
if barstate.islast and i_showDash
    color rowA = c_dashBg
    color rowB = color.new(c_dashBg, 40)
    color lblCol = color.new(c_dashTxt, 25)
    bool tpReordered = not (i_tp1R <= i_tp2R and i_tp2R <= i_tp3R)
    bool volTick = syminfo.volumetype == "tick"
    string tickNote = volTick ? " Volume on this feed is tick volume: a count of trades, not units traded." : ""
    float riskT = math.abs(tEntry - tSl)
    bool openT = tradeDir != 0 and not tradeClosed
    float openR = openT and riskT > 0 ? (close - tEntry) * tradeDir / riskT : na
    table.cell(dash, 0, 0, "  AMFC", text_color = c_dashTxt, text_halign = text.align_left, text_size = size.small, bgcolor = c_dashHdr)
    table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + f_tf(timeframe.period) + "  ", text_color = c_dashTxt, text_halign = text.align_right, text_size = size.small, bgcolor = c_dashHdr)
    int r = 1
    f_row(dash, r, "Lock", i_lockSignal ? "ACTIVE" : "OFF", i_lockSignal ? c_res : c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "")
    r += 1
    f_row(dash, r, "Bias", na(aroonOsc) ? "—" : aroonOsc > 0 ? "Bull" : aroonOsc < 0 ? "Bear" : "Neutral", aroonOsc > 0 ? c_sup : aroonOsc < 0 ? c_res : c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "Sign of the Aroon Oscillator the signals read, smoothed when smoothing is on. No reading until Aroon Length plus one bars exist, and later when smoothing is on.")
    r += 1
    f_row(dash, r, "Aroon Up", na(aroonUp) ? "—" : f_bar(aroonUp, 100.0), na(aroonUp) ? c_dashTxt : f_barColor(aroonUp / 100.0), r % 2 == 1 ? rowA : rowB, lblCol, "Raw, not smoothed. No reading until Aroon Length plus one bars exist.")
    r += 1
    f_row(dash, r, "Aroon Down", na(aroonDn) ? "—" : f_bar(aroonDn, 100.0), na(aroonDn) ? c_dashTxt : f_barColor(aroonDn / 100.0), r % 2 == 1 ? rowA : rowB, lblCol, "Raw, not smoothed. No reading until Aroon Length plus one bars exist.")
    r += 1
    f_row(dash, r, "Aroon Osc", na(aroonOsc) ? "—" : (aroonOsc >= 0 ? "+" : "") + str.tostring(math.round(aroonOsc, 1)), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "The series the signals read: Aroon Up minus Aroon Down, smoothed when smoothing is on. No reading until Aroon Length plus one bars exist, and later when smoothing is on.")
    r += 1
    f_row(dash, r, "CMF", na(cmf) ? "—" : (cmf >= 0 ? "+" : "") + str.tostring(math.round(cmf, 3)), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "Chaikin Money Flow, smoothed when smoothing is on. No reading until CMF Length bars exist, and later when smoothing is on." + tickNote)
    r += 1
    f_row(dash, r, "Money Flow", na(cmf) ? "—" : cmf > i_flowBuf ? "Buying" : cmf < -i_flowBuf ? "Selling" : "Neutral", cmf > i_flowBuf ? c_sup : cmf < -i_flowBuf ? c_res : c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "Chaikin Money Flow against the Flow Buffer, smoothed when smoothing is on. No reading until CMF Length bars exist, and later when smoothing is on." + tickNote)
    r += 1
    f_row(dash, r, "Confirm Bars", str.tostring(confirmEff) + (i_autoConfirm ? " · Auto" : " · Manual"), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "Bars the Aroon flip may come before Chaikin Money Flow agrees. Auto measures it on the chart from past Aroon flips; Manual uses the Confirm Bars input.")
    r += 1
    f_row(dash, r, "Trade", tradeDir == 0 ? "Flat" : (tradeDir == 1 ? "Long" : "Short") + " · " + (slHit ? "Stopped" : tp3Hit ? "Target 3" : tp2Hit ? "Target 2" : tp1Hit ? "Target 1" : "Open"), tradeDir == 1 ? c_sup : tradeDir == -1 ? c_res : c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "")
    r += 1
    f_row(dash, r, "Entry", tradeDir == 0 ? "—" : str.tostring(tEntry, format.mintick), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "")
    r += 1
    f_row(dash, r, "Stop", tradeDir == 0 ? "—" : str.tostring(tSl, format.mintick) + (slHit ? " ✓" : ""), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "")
    r += 1
    f_row(dash, r, "TP1", tradeDir == 0 ? "—" : str.tostring(tTp1, format.mintick) + (tp1Hit ? " ✓" : ""), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "")
    r += 1
    f_row(dash, r, "TP2", tradeDir == 0 ? "—" : str.tostring(tTp2, format.mintick) + (tp2Hit ? " ✓" : ""), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "")
    r += 1
    f_row(dash, r, "TP3", tradeDir == 0 ? "—" : str.tostring(tTp3, format.mintick) + (tp3Hit ? " ✓" : ""), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "")
    r += 1
    f_row(dash, r, "ATR", na(atrVal) ? "—" : str.tostring(atrVal, format.mintick), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "")
    r += 1
    f_row(dash, r, "Open R", na(openR) ? "—" : (openR >= 0 ? "+" : "") + str.tostring(math.round(openR, 2)) + "R", openR > 0 ? c_sup : openR < 0 ? c_res : c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "Open trade result in multiples of the stop distance, at the current close. Not shown once the trade is closed.")
    r += 1
    if i_useHtf
        if htfValid
            f_row(dash, r, "HTF", f_tf(i_htf) + " · " + (na(htfOsc) ? "—" : htfOsc > 0 ? "Bull" : htfOsc < 0 ? "Bear" : "Neutral"), (htfOsc > 0 and aroonOsc > 0) or (htfOsc < 0 and aroonOsc < 0) ? c_barHi : c_barLo, r % 2 == 1 ? rowA : rowB, lblCol, "Higher-timeframe Aroon Oscillator on confirmed bars. Green when it agrees with the current bias.")
        else
            f_row(dash, r, "HTF", f_tf(i_htf) + " · Skipped", c_dashTxt, c_warn, lblCol, "The higher timeframe is lower than the chart timeframe, so the filter is skipped.")
        r += 1
    if i_useAdx
        f_row(dash, r, "ADX Prev", na(adxPrev) ? "—" : str.tostring(math.round(adxPrev, 1)) + " / " + str.tostring(i_adxMin), adxPrev >= i_adxMin ? c_barHi : c_barLo, r % 2 == 1 ? rowA : rowB, lblCol, "ADX of the previous bar against the minimum. No reading until the ADX has enough bars to seed.")
        r += 1
    if i_smoothType != "None"
        f_row(dash, r, "Smoothing", i_smoothType + " " + str.tostring(i_smoothLen), c_dashTxt, r % 2 == 1 ? rowA : rowB, lblCol, "")
        r += 1
    if na(cmfRaw) and bar_index >= i_cmfLen
        f_row(dash, r, "Volume", "None · no signals", c_dashTxt, c_warn, lblCol, "Chaikin Money Flow is undefined because the window holds no volume, so no signal can fire.")
        r += 1
    if tpReordered
        f_row(dash, r, "Targets", "Reordered", c_dashTxt, c_warn, lblCol, "The target multiples were not in increasing order and were sorted nearest to farthest.")
        r += 1
    if r <= 21
        table.clear(dash, 0, r, 1, 21)
if barstate.islast and not i_showDash
    color lblCol = color.new(c_dashTxt, 25)
    bool tpReordered = not (i_tp1R <= i_tp2R and i_tp2R <= i_tp3R)
    int w = 0
    if i_useHtf and not htfValid
        f_row(dash, w, "HTF", f_tf(i_htf) + " · Skipped", c_dashTxt, c_warn, lblCol, "The higher timeframe is lower than the chart timeframe, so the filter is skipped.")
        w += 1
    if na(cmfRaw) and bar_index >= i_cmfLen
        f_row(dash, w, "Volume", "None · no signals", c_dashTxt, c_warn, lblCol, "Chaikin Money Flow is undefined because the window holds no volume, so no signal can fire.")
        w += 1
    if tpReordered
        f_row(dash, w, "Targets", "Reordered", c_dashTxt, c_warn, lblCol, "The target multiples were not in increasing order and were sorted nearest to farthest.")
        w += 1
    if w <= 21
        table.clear(dash, 0, w, 1, 21)
````
