# Stochastic Range Regime [MarkitTick]

- url: https://www.tradingview.com/script/hSH66dWe-Stochastic-Range-Regime-MarkitTick/
- type: indicator
- pine_id: PUB;028ae006067c48b4a932afbaa3b84f28
- version: 1.0

## Description

💡 This overlay classifies every bar as bullish, bearish or neutral by asking two questions at once: is price above or below its moving average, and where does the smoothed Stochastic %K sit inside a range that you define? When both answers agree for enough consecutive bars, the candles take the regime color. When a confirmed regime begins, the script prints a Buy or Sell label at bar close and draws an ATR-based stop with three targets.

The Stochastic is used here as a gauge of position inside the recent high-low range, read in the context of trend direction, and not as a stand-alone overbought and oversold trigger.

[b]✨ Originality and Utility[/b]
The Stochastic Oscillator is normally read against fixed overbought and oversold lines. This script gives the bullish side and the bearish side of the market each their own adjustable %K window. The windows are set separately, they may overlap, and trend direction decides which one applies.

With the default settings the bullish window starts at 40 and has no upper limit, and the bearish window ends at 60 and has no lower limit. In an uptrend, %K only has to stay at or above 40 to keep the regime bullish. In a downtrend, %K only has to stay at or below 60 to keep the regime bearish. A deep pullback against the trend, or a rally against a downtrend, drops the state back to neutral.

What you get from this:
[list]
[*]A three-state read of the market (bullish, bearish, neutral) that is easy to scan on the candles.
[*]Signals only at the moment a confirmed regime begins, instead of a signal on every oscillator cross.
[*]Optional higher timeframe agreement and an optional ADX strength gate.
[*]A complete trade plan drawn on the chart: entry, stop and three targets sized from ATR.
[/list]
[b]● Mashup justification[/b]
The script combines four standard tools, and each one answers a different question.
[list]
[*]The Stochastic %K shows where the close sits inside the recent range. It says nothing about direction.
[*]The simple moving average shows trend direction. It says nothing about where price sits in the recent range.
[*]ADX (optional) measures trend strength without direction, so it can gate signals in weak markets.
[*]ATR measures volatility without direction, so it sizes the stop and targets on the same instrument.
[/list]
The regime needs the first two to agree, and the last two only act as an optional gate and as a sizing tool. Nothing in the combination is merged just for the sake of it: remove the trend average and the regime has no direction, remove the Stochastic and it has no position-in-range condition.

[b]🔬 Methodology and Concepts[/b]
[b]• Step 1: Stochastic position[/b]
The raw Stochastic is 100 times (source minus the lowest low of the last N bars) divided by (the highest high minus the lowest low of the last N bars). It is 0 at the low of the range and 100 at the high. The default length is 14 and the default source is the close. If the highest high equals the lowest low, the bar has no value.

The raw value is then averaged with a simple moving average (default 3 bars) to give %K. Setting %K Smoothing to 1 turns this average off.

Optionally, Adaptive Smoothing applies one more average (EMA, WMA or RMA) on top of %K before the regime is read. With None selected, %K is left exactly as it is.

[b]• Step 2: Trend direction[/b]
A simple moving average of the Trend Source (default close, length 50) decides direction. The trend is up when the source is above the average and down when it is below. If the two are exactly equal, the trend is neither up nor down.

[b]• Step 3: Raw regime[/b]
[list]
[*]Raw bullish: the trend is up and %K is inside the Bull Range (default 40 to 100, both ends included).
[*]Raw bearish: the trend is down and %K is inside the Bear Range (default 0 to 60, both ends included).
[*]If a range is entered with its low above its high, the two values are swapped automatically.
[/list]
[b]• Step 4: Confirmation[/b]
Two counters track how many consecutive bars the raw bullish and raw bearish conditions have held. The confirmed regime becomes bullish or bearish only when its counter reaches Regime Confirm Bars (default 2). Any bar that breaks the raw condition restarts that counter from zero. Everything else is neutral.

[b]• Step 5: Signal[/b]
A signal is issued on a closed bar when the confirmed regime changes into bullish or bearish from any other state. The signal also has to pass these checks:
[list]
[*]The chart must be a standard chart type.
[*]If HTF Confirmation is on, the higher timeframe regime must match.
[*]If the Chop Filter is on, ADX must be at or above the minimum.
[*]The stop and target levels must be valid (see Step 6).
[/list]
The filters are evaluated only on the bar where the regime changes. If a filter blocks the change on that bar, no signal is issued later for the same regime run.

[b]• Step 6: Trade levels[/b]
Entry is the close of the signal bar. The stop sits at entry plus or minus the stop multiple times ATR (default 1.5 times a 14-bar ATR). The three targets sit at the TP multiples times ATR from entry (default 1.0, 2.0 and 3.0). Targets entered out of order are sorted from nearest to farthest.

A signal is suppressed if ATR is not available yet, if the stop distance is not larger than one minimum price tick, or if the levels would reach zero or below (the stop for a long, the farthest target for a short).

[b]• Step 7: Trade tracking[/b]
[list]
[*]Targets are marked as hit when the bar's high (long) or low (short) reaches them.
[*]The stop is marked as hit only when a bar closes beyond it, not on a wick.
[*]When the third target is hit, or the stop is hit, the trade is considered closed.
[*]After a stop, later target touches are ignored.
[*]If a new signal appears while the previous trade is still open, the old trade is closed by the new one and its drawings are replaced.
[/list]
[b]🎨 Visual Guide[/b]
[list]
[*]Regime candles: the script draws its own candles. Teal green means a confirmed bullish regime, red means a confirmed bearish regime and gray means neutral. These are the default colors and can be changed in the Colors group. Switching off Color Candles removes them.
[*]Buy label: appears below the signal bar, pointing up, in the bullish color with white text.
[*]Sell label: appears above the signal bar, pointing down, in the bearish color with white text.
[*]Stop line: a solid red line, drawn from the signal bar to the right.
[*]Entry line: a dashed blue line at the signal bar close.
[*]Target lines: three dashed teal lines. TP1 is the lightest and TP3 the most solid.
[*]Level labels: sit at the right end of each line and show the price. If two levels round to the same price they share one label, for example Entry and TP1 together.
[*]Hit labels: when a target is reached its label text changes to show that it was hit, with the percentage move from entry. The stop label does the same, using the closing price of the bar that closed beyond it.
[*]Line length: while a trade is open the lines extend ten bars beyond the latest bar. After a trade closes they stop ten bars after the closing bar.
[/list]
[b]• Dashboard[/b]
A two-column table in the corner you choose. The header shows SRR with the symbol and timeframe. The rows are:
[list]
[*]Lock: whether the signal lock is active.
[*]Regime: Bullish, Bearish or Neutral. It shows a dash until enough bars have filled.
[*]Stochastic %K: a ten-block bar with its percentage value.
[*]Bull Range and Bear Range: the two windows in use after any automatic swap.
[*]Trend: Up or Down.
[*]ADX Strength: a ten-block bar with its value.
[*]Chop Filter: Pass or Blocked (shown only when the filter is on).
[*]HTF Regime: the higher timeframe state, or Skipped (shown only when HTF Confirmation is on).
[*]Adaptive Smoothing: the method and length (shown only when a method is selected).
[*]Confirm Bars: the current count against the number required.
[*]ATR Value, Trade status, Entry, Stop, TP1, TP2 and TP3, with a check mark added to a level once it has been hit.
[/list]
The progress bars are green at 66 percent or more of the scale, amber from 33 percent and red below that. This coloring reflects where the value sits on the 0 to 100 scale. It is not a verdict on the market.

Rows with a tinted warning fill appear when the HTF timeframe is lower than the chart timeframe (the filter is skipped) or when the target multiples were entered out of order and were sorted.

[b]• Standard charts only[/b]
On Heikin Ashi, Renko, Kagi, Point and Figure, Range and Line Break charts the script shows a red notice in the middle of the chart. It draws no candles and issues no signals there, because those chart types show synthetic prices.

[b]📖 How to Use[/b]
[list=1]
[*]Add the script to a standard candlestick chart. The first bars show a dash on the dashboard until the Stochastic, its smoothing and the trend average have enough history.
[*]Read the candle colors as the current regime. Gray candles mean that trend direction and %K position do not agree, or that the confirmation count has not been completed yet.
[*]Use the Confirm Bars row to see how close a new regime is to being confirmed.
[*]A Buy or Sell label marks the first closed bar of a newly confirmed regime. The drawn entry, stop and targets belong to that signal.
[*]Watch the Trade row and the hit labels to follow the trade state. Stopped means a close beyond the stop, and Targets Done means the third target was reached.
[*]Tighten or widen the windows to change how demanding the regime is. For example, a higher Bull Range Low requires the close to sit higher inside the recent range before a bullish regime counts.
[*]Turn on HTF Confirmation to require the same regime on a higher timeframe, or the Chop Filter to ignore regime changes while ADX is below your minimum.
[/list]
A regime describes current conditions. It is not a forecast, and the stop and targets are fixed ATR distances, not predictions.

[b]● Alerts[/b]
Seven alert conditions are available: Buy Signal, Sell Signal, Close On New Signal, TP1 Hit, TP2 Hit, TP3 Hit and Stop Hit.

The script also sends message-style alerts. Entry alerts carry the action word, ticker, timeframe, direction, entry, stop, the three targets and the regime. Exit alerts carry the action word, ticker, timeframe, direction, entry, stop and the target that was hit. Partial close messages are used for TP1 and TP2, and close messages for TP3, the stop or a new signal.

Entry, stop and new-signal alerts are sent at bar close. Target alerts are sent once per bar, as soon as the target is touched.

[b]● Bar-close behavior and repainting warning[/b]
[list]
[*]Signals, labels and entry levels are created only on a closed bar and do not change afterwards.
[*]While a bar is still forming, the candle color, the Regime row, the %K bar and the other dashboard values can change as price moves, and they settle at the close. Do not treat the color of the live bar as final.
[*]Target hit marks and their alerts react to the bar's high or low while the bar is open.
[*]When one bar touches several levels, the order in which they were touched is not known from bar data. Targets are marked by the bar range and the stop by the close.
[*]HTF Confirmation reads the last completed higher timeframe bar, so that value does not change while the higher timeframe bar is forming.
[/list]
[b]⚙️ Inputs and Settings[/b]
[b]• Core Settings[/b]
[list]
[*]Stochastic Length (default 14): the look-back of the high-low range. A longer range makes %K move more slowly.
[*]%K Smoothing (default 3): the simple average applied to the raw value. 1 turns it off.
[*]Source: the price placed inside the range (default close).
[*]Trend MA Length (default 50) and Trend Source (default close): the moving average and the price compared against it.
[/list]
[b]• Filters[/b]
[list]
[*]Bull Range Low and High (default 40 and 100): the %K window that counts as bullish when the trend is up.
[*]Bear Range Low and High (default 0 and 60): the %K window that counts as bearish when the trend is down.
[*]Regime Confirm Bars (default 2): consecutive bars needed before a regime counts. Higher values mean fewer flips and later signals.
[*]Use HTF Confirmation and HTF Timeframe (default off, 240): require the same regime on the higher timeframe. A timeframe lower than the chart is skipped and the dashboard says so.
[*]Use Chop Filter, ADX Length and ADX Min Strength (default off, 14, 20): block signals when ADX is below the minimum.
[*]Adaptive Smoothing and its length (default None, 5): extra smoothing of %K with EMA, WMA or RMA. The higher timeframe regime uses the same setting.
[/list]
[b]• Trade Tools[/b]
[list]
[*]Lock Signal (default off): blocks new signals on the latest bar so the trade currently drawn stays as it is. Signals on earlier bars are not affected.
[*]ATR Length (default 14): the volatility measure that sizes the levels.
[*]SL ATR Mult (default 1.5) and TP1, TP2, TP3 ATR Mult (default 1.0, 2.0, 3.0): the distances from entry in ATR units.
[/list]
[b]• Visuals, Dashboard, Alerts and Colors[/b]
[list]
[*]Color Candles and Show Buy/Sell Signals switch the regime candles and the signal labels on or off.
[*]Show Dashboard and Dashboard Position control the table and its corner.
[*]The Alerts group sets the action words sent in the message-style alerts (long, short, close long, close short, partial close long, partial close short).
[*]The Colors group sets the regime, level line, label, dashboard and warning colors.
[/list]
[b]● Trade level notes[/b]
This is an indicator, not a backtesting strategy. It has no performance report, and it shows no win rate or profit figures. The stop and the three targets are fixed multiples of ATR. With the defaults, the third target sits at twice the stop distance (3.0 divided by 1.5). Position size, risk per trade and the decision to act on any signal remain yours.

Past behavior of a regime or of a signal does not guarantee that it will repeat.

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]
[b]• Range normalization[/b]
The Stochastic Oscillator is credited to George C. Lane in the 1950s. It places the latest price inside the high-low range of the last N bars, from 0 at the low to 100 at the high. Because the result is bounded, the readings can be compared between instruments with very different price levels. Lane's premise is that momentum changes direction before price does.

[b]• Why the raw value is smoothed[/b]
The raw value can jump when the oldest bar leaves the look-back window, which is why Lane averaged it before using it. Averaging smooths the series but adds lag, so the smoothing length trades noise against delay. The optional Adaptive Smoothing methods weight the window differently from the plain average and follow the same trade-off.

[b]• Position in range read together with trend[/b]
It is widely noted that an overbought or oversold reading does not by itself mean a reversal, and that in a strong trend the oscillator can stay near an extreme for a long time. Lane also considered his signals more reliable when taken in the direction of the major trend. Reading %K position only when it agrees with the direction of a moving average follows from these points. The upper part of the range is accepted inside a bullish regime and the lower part inside a bearish one.

[b]• The trend filter[/b]
The simple moving average is the equal-weight mean of the last N values. A price above or below an average is the usual way to read direction. It is widely noted that the average lags, that crossovers arrive late and that it whipsaws in trading ranges. These are the conditions where the neutral state and the optional ADX gate are meant to help.

[b]• Persistence rule[/b]
The confirmation counters turn the raw condition into a state that must hold for a number of consecutive bars. This is a simple debounce. It reduces one-bar flips, and its cost is that a regime appears later by the number of confirmation bars minus one.

[b]• Volatility scaling with ATR[/b]
J. Welles Wilder introduced the true range and the Average True Range in 1978. True range is the largest of the high minus the low, the high minus the previous close, and the low minus the previous close, so gaps are included. ATR smooths it, and the built-in version is the RMA of true range. ATR measures how much price typically moves per bar and says nothing about direction. It is expressed in price units, so it should be used on the instrument it was measured on. Setting the stop and targets in ATR multiples lets the distances follow current volatility.

[b]• Trend strength with ADX[/b]
Wilder also created the Directional Movement Index and the ADX in 1978, as a filter to keep a trader out of sideways markets. ADX measures how strong a trend is without giving its direction. Readings above 25 are commonly read as a strong trend and readings below 20 as a weak or absent one, with the area between as indeterminate. ADX is built from several layers of smoothing, so it lags and can whipsaw, and other analysis is needed to confirm what it shows. The default minimum of 20 in this script sits at that boundary.

[b]• Higher timeframe agreement[/b]
When enabled, the same regime calculation is repeated on the chosen higher timeframe and read from its last completed bar. The signal then needs both timeframes to point the same way.

[b]• Limits[/b]
Every input here is a rolling calculation on past bars, so the script describes conditions that already exist. It does not predict price.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. We expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick
//@version=6
indicator("Stochastic Range Regime [MarkitTick]", overlay = true, behind_chart = false)

// ── INPUTS ──────────────────────────────────────────────────────
var string GRP_CORE = "⚙️ Core Settings"
i_stochLen = input.int(14, "Stochastic Length", minval = 1, maxval = 200, step = 1, group = GRP_CORE, tooltip = "Look-back, in bars, of the highest-high / lowest-low range the close is placed in.")
i_kSmooth = input.int(3, "%K Smoothing", minval = 1, maxval = 50, step = 1, group = GRP_CORE, tooltip = "Bars of simple average applied to the raw Stochastic. 1 turns the smoothing off.")
i_stochSrc = input.source(close, "Source", group = GRP_CORE, tooltip = "Price the Stochastic places inside the high-low range.")
i_trendLen = input.int(50, "Trend MA Length", minval = 1, maxval = 500, step = 1, group = GRP_CORE, tooltip = "Length of the simple moving average that decides trend direction.")
i_trendSrc = input.source(close, "Trend Source", group = GRP_CORE, tooltip = "Price compared against the trend average.")

var string GRP_FILT = "🕯️ Filters"
i_bullLo = input.int(40, "Bull Range Low", minval = 0, maxval = 100, step = 1, group = GRP_FILT, tooltip = "%K must be at or above this value, with price above its trend average, for a bullish regime. If set above Bull Range High, the two values are swapped.")
i_bullHi = input.int(100, "Bull Range High", minval = 0, maxval = 100, step = 1, group = GRP_FILT, tooltip = "%K must be at or below this value for a bullish regime. 100 means no upper limit. If set below Bull Range Low, the two values are swapped.")
i_bearLo = input.int(0, "Bear Range Low", minval = 0, maxval = 100, step = 1, group = GRP_FILT, tooltip = "%K must be at or above this value, with price below its trend average, for a bearish regime. 0 means no lower limit. If set above Bear Range High, the two values are swapped.")
i_bearHi = input.int(60, "Bear Range High", minval = 0, maxval = 100, step = 1, group = GRP_FILT, tooltip = "%K must be at or below this value for a bearish regime. If set below Bear Range Low, the two values are swapped.")
i_confirmBars = input.int(2, "Regime Confirm Bars", minval = 1, maxval = 20, step = 1, group = GRP_FILT, tooltip = "Consecutive bars the raw regime must hold before it counts.")
i_useHtf = input.bool(false, "Use HTF Confirmation", group = GRP_FILT, tooltip = "Requires the same regime on the higher timeframe.")
i_htfTF = input.timeframe("240", "HTF Timeframe", group = GRP_FILT, tooltip = "Higher timeframe used when HTF confirmation is on. It must be not lower than the chart timeframe; a lower one is skipped and shown on the dashboard.")
i_useAdx = input.bool(false, "Use Chop Filter", group = GRP_FILT, tooltip = "Blocks signals when ADX is below the minimum.")
i_adxLen = input.int(14, "ADX Length", minval = 1, maxval = 100, step = 1, group = GRP_FILT, tooltip = "Length used for the ADX.")
i_adxMin = input.int(20, "ADX Min Strength", minval = 0, maxval = 100, step = 1, group = GRP_FILT, tooltip = "Minimum ADX for a signal to pass the chop filter.")
i_smoothType = input.string("None", "Adaptive Smoothing", options = ["None", "EMA", "WMA", "RMA"], group = GRP_FILT, tooltip = "Extra smoothing applied to %K after the %K Smoothing, before the regime is read. None leaves %K exactly as it is. The HTF regime uses the same setting.")
i_smoothLen = input.int(5, "Adaptive Smoothing Length", minval = 1, maxval = 50, step = 1, group = GRP_FILT, tooltip = "Length, in bars, of the adaptive smoothing method. Not used while the method is None.")

var string GRP_TT = "📐 Trade Tools"
i_lockSignal = input.bool(false, "Lock Signal", group = GRP_TT, tooltip = "Freeze current signal · block new ones")
i_atrLen = input.int(14, "ATR Length", minval = 1, maxval = 100, step = 1, group = GRP_TT, tooltip = "Length of the ATR that sizes stop and targets.")
i_slMult = input.float(1.5, "SL ATR Mult", minval = 0.1, maxval = 10.0, step = 0.1, group = GRP_TT, tooltip = "Stop distance from entry, in ATRs.")
i_tp1Mult = input.float(1.0, "TP1 ATR Mult", minval = 0.1, maxval = 20.0, step = 0.1, group = GRP_TT, tooltip = "First target distance from entry, in ATRs. Targets entered out of order are sorted nearest to farthest.")
i_tp2Mult = input.float(2.0, "TP2 ATR Mult", minval = 0.1, maxval = 20.0, step = 0.1, group = GRP_TT, tooltip = "Second target distance from entry, in ATRs. Targets entered out of order are sorted nearest to farthest.")
i_tp3Mult = input.float(3.0, "TP3 ATR Mult", minval = 0.1, maxval = 20.0, step = 0.1, group = GRP_TT, tooltip = "Third target distance from entry, in ATRs. Targets entered out of order are sorted nearest to farthest.")

var string GRP_VIS = "🎨 Visuals"
i_colorCandles = input.bool(true, "Color Candles", group = GRP_VIS, tooltip = "Colors the candles by regime.")
i_showSignals = input.bool(true, "Show Buy/Sell Signals", group = GRP_VIS, tooltip = "Prints a BUY or SELL label on the signal bar.")

var string GRP_DASH = "📊 Dashboard"
i_showDash = input.bool(true, "Show Dashboard", group = GRP_DASH, tooltip = "Shows the dashboard table on the chart.")
i_dashPos = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH, tooltip = "Corner of the chart the dashboard is drawn in.")

var string GRP_WH = "🔔 Alerts"
i_actLong = input.string("long", "↑ Long Action", group = GRP_WH, tooltip = "Action word sent in the long entry payload.")
i_actShort = input.string("short", "↓ Short Action", group = GRP_WH, tooltip = "Action word sent in the short entry payload.")
i_actCloseLong = input.string("closelong", "✕ Close Long Action", group = GRP_WH, tooltip = "Action word sent when a long trade is closed.")
i_actCloseShort = input.string("closeshort", "✕ Close Short Action", group = GRP_WH, tooltip = "Action word sent when a short trade is closed.")
i_actPartLong = input.string("partialcloselong", "✕ Partial Close Long Action", group = GRP_WH, tooltip = "Action word sent when a target that is not the last one is hit on a long trade.")
i_actPartShort = input.string("partialcloseshort", "✕ Partial Close Short Action", group = GRP_WH, tooltip = "Action word sent when a target that is not the last one is hit on a short trade.")

var string GRP_COL = "🌈 Colors"
C_SUP = input.color(#26a69a, "Bullish", group = GRP_COL, tooltip = "Bullish regime: candles, labels and dashboard values.")
C_RES = input.color(#ef5350, "Bearish", group = GRP_COL, tooltip = "Bearish regime: candles, labels and dashboard values.")
C_NEUT = input.color(#787b86, "Neutral Candle", group = GRP_COL, tooltip = "Candle color while the regime is neutral.")
C_SL = input.color(#ef5350, "SL Line", group = GRP_COL, tooltip = "Stop line and label. The label is drawn at full opacity.")
C_ENTRY = input.color(#2196f3, "Entry Line", group = GRP_COL, tooltip = "Entry line and label. The label is drawn at full opacity.")
C_TP1 = input.color(color.new(#26a69a, 40), "TP1 Line", group = GRP_COL, tooltip = "First target line and label. The label is drawn at full opacity.")
C_TP2 = input.color(color.new(#26a69a, 20), "TP2 Line", group = GRP_COL, tooltip = "Second target line and label. The label is drawn at full opacity.")
C_TP3 = input.color(color.new(#26a69a, 0), "TP3 Line", group = GRP_COL, tooltip = "Third target line and label. The label is drawn at full opacity.")
C_MID = input.color(#f9a825, "Progress Mid", group = GRP_COL, tooltip = "Middle band of the dashboard progress bars.")
C_DASH_HDR = input.color(color.new(#3a2a6d, 55), "Dashboard Header", group = GRP_COL, tooltip = "Dashboard header fill.")
C_DASH_BG = input.color(color.new(#0a0f1a, 10), "Dashboard Background", group = GRP_COL, tooltip = "Dashboard row fill.")
C_DASH_TXT = input.color(#ffffff, "Dashboard Text", group = GRP_COL, tooltip = "Dashboard text and neutral values.")
C_WARN = input.color(color.new(#f9a825, 80), "Dashboard Warning", group = GRP_COL, tooltip = "Fill of a dashboard row that warns of a skipped or reordered setting.")
C_SIGTXT = input.color(color.white, "Signal Label Text", group = GRP_COL, tooltip = "Text of the BUY and SELL signal labels.")

// ── CORE LOGIC ──────────────────────────────────────────────────
bool stdChart = chart.is_standard
int bullLo = math.min(i_bullLo, i_bullHi)
int bullHi = math.max(i_bullLo, i_bullHi)
int bearLo = math.min(i_bearLo, i_bearHi)
int bearHi = math.max(i_bearLo, i_bearHi)
float tpM1 = math.min(i_tp1Mult, i_tp2Mult, i_tp3Mult)
float tpM3 = math.max(i_tp1Mult, i_tp2Mult, i_tp3Mult)
float tpM2 = math.max(math.min(i_tp1Mult, i_tp2Mult), math.min(math.max(i_tp1Mult, i_tp2Mult), i_tp3Mult))

f_regimeCore() =>
    float _hh = ta.highest(high, i_stochLen)
    float _ll = ta.lowest(low, i_stochLen)
    float _rawStoch = ta.stoch(i_stochSrc, high, low, i_stochLen)
    float _raw = _hh == _ll ? float(na) : _rawStoch
    float _kBase = ta.sma(_raw, i_kSmooth)
    float _kEma = ta.ema(_kBase, i_smoothLen)
    float _kWma = ta.wma(_kBase, i_smoothLen)
    float _kRma = ta.rma(_kBase, i_smoothLen)
    float _k = i_smoothType == "EMA" ? _kEma : i_smoothType == "WMA" ? _kWma : i_smoothType == "RMA" ? _kRma : _kBase
    float _trendMa = ta.sma(i_trendSrc, i_trendLen)
    bool _up = i_trendSrc > _trendMa
    bool _down = i_trendSrc < _trendMa
    bool _bullRaw = _up and _k >= bullLo and _k <= bullHi
    bool _bearRaw = _down and _k >= bearLo and _k <= bearHi
    var int _bullCnt = 0
    var int _bearCnt = 0
    _bullCnt := _bullRaw ? _bullCnt + 1 : 0
    _bearCnt := _bearRaw ? _bearCnt + 1 : 0
    int _state = _bullRaw and _bullCnt >= i_confirmBars ? 1 : _bearRaw and _bearCnt >= i_confirmBars ? -1 : 0
    [_k, _up, _down, _bullRaw, _bearRaw, _bullCnt, _bearCnt, _state, _trendMa]

f_regimeState() =>
    [_k, _up, _down, _bullRaw, _bearRaw, _bullCnt, _bearCnt, _state, _trendMa] = f_regimeCore()
    _state

[stochK, trendUp, trendDown, bullRaw, bearRaw, bullCnt, bearCnt, regimeState, trendMaVal] = f_regimeCore()
int prevRegime = nz(regimeState[1])

bool htfSkipped = i_useHtf and timeframe.in_seconds(i_htfTF) < timeframe.in_seconds()
bool htfOn = i_useHtf and not htfSkipped
int htfState = htfOn ? request.security(syminfo.tickerid, i_htfTF, f_regimeState()[1], lookahead = barmerge.lookahead_on) : int(na)
bool htfBullOk = not htfOn or htfState == 1
bool htfBearOk = not htfOn or htfState == -1

[diPlus, diMinus, adxVal] = ta.dmi(i_adxLen, i_adxLen)
bool chopOk = not i_useAdx or adxVal >= i_adxMin

float atrVal = ta.atr(i_atrLen)
float riskDist = atrVal * i_slMult
float atrTp3 = atrVal * tpM3
bool lvlBaseOk = not na(atrVal) and riskDist > syminfo.mintick
bool lvlOkLong = lvlBaseOk and close - riskDist > 0
bool lvlOkShort = lvlBaseOk and close - atrTp3 > 0

bool rawLong = stdChart and barstate.isconfirmed and regimeState == 1 and prevRegime != 1 and htfBullOk and chopOk and lvlOkLong
bool rawShort = stdChart and barstate.isconfirmed and regimeState == -1 and prevRegime != -1 and htfBearOk and chopOk and lvlOkShort

float cEntry = close
float cSl = rawLong ? close - riskDist : close + riskDist
float atrTp1 = atrVal * tpM1
float atrTp2 = atrVal * tpM2
float cTp1 = rawLong ? close + atrTp1 : close - atrTp1
float cTp2 = rawLong ? close + atrTp2 : close - atrTp2
float cTp3 = rawLong ? close + atrTp3 : close - atrTp3

var int tradeDir = 0
var int tradeBar = int(na)
var float tradeEntry = float(na)
var float tradeSl = float(na)
var float tradeTp1 = float(na)
var float tradeTp2 = float(na)
var float tradeTp3 = float(na)
var int tradeL1 = 2
var int tradeL2 = 3
var int tradeL3 = 4
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool slHit = false
var int _closeBar = int(na)
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
var label sigLbl = na

f_same(float a, float b) =>
    math.round_to_mintick(a) == math.round_to_mintick(b)

f_join(string s, string t) =>
    s == "" ? t : s + " / " + t

f_grpTxt(int idx) =>
    string s = idx == 1 ? "Entry" : ""
    if tradeL1 == idx
        s := f_join(s, "TP1")
    if tradeL2 == idx
        s := f_join(s, "TP2")
    if tradeL3 == idx
        s := f_join(s, "TP3")
    s

f_pendTxt(int idx, float price) =>
    (idx == 1 ? "▶ " : idx == 3 ? "✦ " : "◆ ") + f_grpTxt(idx) + " " + str.tostring(price, format.mintick)

f_lblOf(int idx) =>
    idx == 1 ? entryLbl : idx == 2 ? tp1Lbl : idx == 3 ? tp2Lbl : tp3Lbl

f_pctTxt(float lvl, float entry, bool isLong) =>
    float _p = (isLong ? lvl - entry : entry - lvl) / entry * 100
    (_p >= 0 ? "+" : "") + str.tostring(_p, "0.00") + "%"

f_deleteLevels() =>
    line.delete(slLine)
    line.delete(entryLine)
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    label.delete(slLbl)
    label.delete(entryLbl)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)

bool tradeLive = tradeDir != 0 and bar_index > tradeBar
bool _tp1Cross = tradeLive and (tradeDir == 1 ? high >= tradeTp1 : low <= tradeTp1)
bool _tp2Cross = tradeLive and (tradeDir == 1 ? high >= tradeTp2 : low <= tradeTp2)
bool _tp3Cross = tradeLive and (tradeDir == 1 ? high >= tradeTp3 : low <= tradeTp3)
bool _slCross = tradeLive and barstate.isconfirmed and (tradeDir == 1 ? close < tradeSl : close > tradeSl)

bool tp1New = _tp1Cross and not tp1Hit and not slHit
bool tp2New = _tp2Cross and not tp2Hit and not slHit
bool tp3New = _tp3Cross and not tp3Hit and not slHit

if tp1New
    tp1Hit := true
    label _hl1 = f_lblOf(tradeL1)
    if not na(_hl1)
        label.set_text(_hl1, f_grpTxt(tradeL1) + " ✓ HIT " + f_pctTxt(tradeTp1, tradeEntry, tradeDir == 1))
if tp2New
    tp2Hit := true
    label _hl2 = f_lblOf(tradeL2)
    if not na(_hl2)
        label.set_text(_hl2, f_grpTxt(tradeL2) + " ✓ HIT " + f_pctTxt(tradeTp2, tradeEntry, tradeDir == 1))
if tp3New
    tp3Hit := true
    label _hl3 = f_lblOf(tradeL3)
    if not na(_hl3)
        label.set_text(_hl3, f_grpTxt(tradeL3) + " ✓ HIT " + f_pctTxt(tradeTp3, tradeEntry, tradeDir == 1))

bool slNew = _slCross and not slHit and not tp3Hit
if slNew
    slHit := true
    if not na(slLbl)
        label.set_text(slLbl, "SL ✓ HIT " + f_pctTxt(close, tradeEntry, tradeDir == 1))

bool _tradeClosed = slHit or tp3Hit
if tradeDir != 0 and _tradeClosed and na(_closeBar)
    _closeBar := bar_index

bool _locked = i_lockSignal and barstate.islast
bool newLong = rawLong and not _locked
bool newShort = rawShort and not _locked
bool newSignal = newLong or newShort
bool closeOld = newSignal and tradeDir != 0 and not _tradeClosed

// ── ALERTS ──────────────────────────────────────────────────────
f_esc(string s) =>
    str.replace_all(str.replace_all(s, "\\", "\\\\"), "\"", "\\\"")

f_q(float v) =>
    na(v) ? "null" : str.format("\"{0}\"", str.tostring(v, format.mintick))

f_entryPayload(string action, string dir, float entry, float sl, float t1, float t2, float t3, string regime) =>
    string _inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":{4},"sl":{5},"tp1":{6},"tp2":{7},"tp3":{8},"regime":"{9}"',
     f_esc(action), f_esc(syminfo.tickerid), f_esc(timeframe.period), dir, f_q(entry), f_q(sl), f_q(t1), f_q(t2), f_q(t3), regime)
    "{" + _inner + "}"

f_exitPayload(string action, string dir, float entry, float sl, float tp) =>
    string _inner = str.format('"action":"{0}","ticker":"{1}","tf":"{2}","direction":"{3}","entry":{4},"sl":{5},"tp":{6}',
     f_esc(action), f_esc(syminfo.tickerid), f_esc(timeframe.period), dir, f_q(entry), f_q(sl), f_q(tp))
    "{" + _inner + "}"

if tp1New
    alert(f_exitPayload(tradeDir == 1 ? i_actPartLong : i_actPartShort, tradeDir == 1 ? "long" : "short", tradeEntry, tradeSl, tradeTp1), alert.freq_once_per_bar)
if tp2New
    alert(f_exitPayload(tradeDir == 1 ? i_actPartLong : i_actPartShort, tradeDir == 1 ? "long" : "short", tradeEntry, tradeSl, tradeTp2), alert.freq_once_per_bar)
if tp3New
    alert(f_exitPayload(tradeDir == 1 ? i_actCloseLong : i_actCloseShort, tradeDir == 1 ? "long" : "short", tradeEntry, tradeSl, tradeTp3), alert.freq_once_per_bar)
if slNew and barstate.isconfirmed
    alert(f_exitPayload(tradeDir == 1 ? i_actCloseLong : i_actCloseShort, tradeDir == 1 ? "long" : "short", tradeEntry, tradeSl, float(na)), alert.freq_once_per_bar_close)
if closeOld and barstate.isconfirmed
    alert(f_exitPayload(tradeDir == 1 ? i_actCloseLong : i_actCloseShort, tradeDir == 1 ? "long" : "short", tradeEntry, tradeSl, float(na)), alert.freq_once_per_bar_close)
if newLong and barstate.isconfirmed
    alert(f_entryPayload(i_actLong, "long", cEntry, cSl, cTp1, cTp2, cTp3, "bull"), alert.freq_once_per_bar_close)
if newShort and barstate.isconfirmed
    alert(f_entryPayload(i_actShort, "short", cEntry, cSl, cTp1, cTp2, cTp3, "bear"), alert.freq_once_per_bar_close)

alertcondition(newLong and barstate.isconfirmed, "BUY Signal", "MarkitTick — BUY Signal Fired")
alertcondition(newShort and barstate.isconfirmed, "SELL Signal", "MarkitTick — SELL Signal Fired")
alertcondition(closeOld and barstate.isconfirmed, "Close On New Signal", "MarkitTick — Trade Closed By New Signal")
alertcondition(tp1New, "TP1 Hit", "MarkitTick — TP1 Hit")
alertcondition(tp2New, "TP2 Hit", "MarkitTick — TP2 Hit")
alertcondition(tp3New, "TP3 Hit", "MarkitTick — TP3 Hit")
alertcondition(slNew and barstate.isconfirmed, "Stop Hit", "MarkitTick — Stop Hit")

// ── VISUALS ─────────────────────────────────────────────────────
color candleColor = stdChart and i_colorCandles ? (regimeState == 1 ? C_SUP : regimeState == -1 ? C_RES : C_NEUT) : na
plotcandle(open, high, low, close, title = "Regime Candles", color = candleColor, wickcolor = candleColor, bordercolor = candleColor)

if newSignal
    f_deleteLevels()
    label.delete(sigLbl)
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
    sigLbl := na
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit := false
    _closeBar := int(na)
    tradeDir := newLong ? 1 : -1
    tradeBar := bar_index
    tradeEntry := cEntry
    tradeSl := cSl
    tradeTp1 := cTp1
    tradeTp2 := cTp2
    tradeTp3 := cTp3
    tradeL1 := f_same(cTp1, cEntry) ? 1 : 2
    tradeL2 := f_same(cTp2, cEntry) ? 1 : f_same(cTp2, cTp1) ? 2 : 3
    tradeL3 := f_same(cTp3, cEntry) ? 1 : f_same(cTp3, cTp1) ? 2 : f_same(cTp3, cTp2) ? 3 : 4
    if i_showSignals
        if newLong
            sigLbl := label.new(bar_index, low, "BUY", yloc = yloc.belowbar, style = label.style_label_up, color = C_SUP, textcolor = C_SIGTXT, size = size.small)
        else
            sigLbl := label.new(bar_index, high, "SELL", yloc = yloc.abovebar, style = label.style_label_down, color = C_RES, textcolor = C_SIGTXT, size = size.small)
    slLine := line.new(bar_index, cSl, bar_index + 1, cSl, color = C_SL, style = line.style_solid, width = 2)
    entryLine := line.new(bar_index, cEntry, bar_index + 1, cEntry, color = C_ENTRY, style = line.style_dashed, width = 1)
    tp1Line := line.new(bar_index, cTp1, bar_index + 1, cTp1, color = C_TP1, style = line.style_dashed, width = 1)
    tp2Line := line.new(bar_index, cTp2, bar_index + 1, cTp2, color = C_TP2, style = line.style_dashed, width = 1)
    tp3Line := line.new(bar_index, cTp3, bar_index + 1, cTp3, color = C_TP3, style = line.style_dashed, width = 1)
    slLbl := label.new(bar_index + 1, cSl, "✕ SL " + str.tostring(cSl, format.mintick), style = label.style_label_left, color = color.new(C_SL, 0), textcolor = color.white, size = size.small)
    entryLbl := label.new(bar_index + 1, cEntry, f_pendTxt(1, cEntry), style = label.style_label_left, color = color.new(C_ENTRY, 0), textcolor = color.white, size = size.small)
    if tradeL1 == 2
        tp1Lbl := label.new(bar_index + 1, cTp1, f_pendTxt(2, cTp1), style = label.style_label_left, color = color.new(C_TP1, 0), textcolor = color.white, size = size.small)
    if tradeL2 == 3
        tp2Lbl := label.new(bar_index + 1, cTp2, f_pendTxt(3, cTp2), style = label.style_label_left, color = color.new(C_TP2, 0), textcolor = color.white, size = size.small)
    if tradeL3 == 4
        tp3Lbl := label.new(bar_index + 1, cTp3, f_pendTxt(4, cTp3), style = label.style_label_left, color = color.new(C_TP3, 0), textcolor = color.white, size = size.small)

bool _extUpdate = _tradeClosed ? _closeBar == bar_index : barstate.islast
if not na(slLine) and _extUpdate
    int _extX = _tradeClosed ? _closeBar + 10 : last_bar_index + 10
    line.set_x2(slLine, _extX)
    line.set_x2(entryLine, _extX)
    line.set_x2(tp1Line, _extX)
    line.set_x2(tp2Line, _extX)
    line.set_x2(tp3Line, _extX)
    label.set_x(slLbl, _extX)
    label.set_x(entryLbl, _extX)
    if not na(tp1Lbl)
        label.set_x(tp1Lbl, _extX)
    if not na(tp2Lbl)
        label.set_x(tp2Lbl, _extX)
    if not na(tp3Lbl)
        label.set_x(tp3Lbl, _extX)

// ── DASHBOARD ───────────────────────────────────────────────────
f_tf(string tf) =>
    int _s = timeframe.isticks and tf == timeframe.period ? 0 : timeframe.in_seconds(tf)
    timeframe.isticks and tf == timeframe.period ? str.tostring(timeframe.multiplier) + "t" : _s % 604800 == 0 ? str.tostring(int(_s / 604800)) + "W" : _s % 86400 == 0 ? str.tostring(int(_s / 86400)) + "D" : _s >= 2628003 ? str.tostring(math.round(_s / 2628003.0)) + "M" : _s % 3600 == 0 ? str.tostring(int(_s / 3600)) + "H" : _s % 60 == 0 ? str.tostring(int(_s / 60)) + "m" : str.tostring(_s) + "s"

f_bar(float val, float maxVal) =>
    int _filled = math.round(math.min(val / maxVal, 1.0) * 10)
    string _bar = ""
    for i = 1 to 10
        _bar += i <= _filled ? "█" : "░"
    _bar + "  " + str.tostring(math.round(val / maxVal * 100)) + "%"

f_barColor(float pct) =>
    pct >= 0.66 ? C_SUP : pct >= 0.33 ? C_MID : C_RES

f_bg(int r) =>
    r % 2 == 1 ? C_DASH_BG : color.new(C_DASH_BG, 40)

f_row(table t, int r, string lbl, string val, color clr, color bg, string tip) =>
    table.cell(t, 0, r, "  " + lbl, text_color = color.new(C_DASH_TXT, 25), text_halign = text.align_left, bgcolor = bg, text_size = size.small, tooltip = tip)
    table.cell(t, 1, r, val + "  ", text_color = clr, text_halign = text.align_right, bgcolor = bg, text_size = size.small, tooltip = tip)

string dashPos = i_dashPos == "Top Left" ? position.top_left : i_dashPos == "Bottom Right" ? position.bottom_right : i_dashPos == "Bottom Left" ? position.bottom_left : position.top_right
var table dash = table.new(dashPos, 2, 22, border_width = 1, border_color = color.new(#2a3040, 40), frame_width = 1, frame_color = color.new(#3a2a6d, 40))
var table notice = table.new(position.middle_center, 1, 2, force_overlay = true)

if barstate.islast
    table.clear(dash, 0, 0, 1, 21)
    if stdChart
        int r = 0
        if i_showDash
            table.cell(dash, 0, 0, "  SRR", text_color = C_DASH_TXT, text_halign = text.align_left, bgcolor = C_DASH_HDR, text_size = size.small)
            table.cell(dash, 1, 0, syminfo.ticker + "  ·  " + f_tf(timeframe.period) + "  ", text_color = C_DASH_TXT, text_halign = text.align_right, bgcolor = C_DASH_HDR, text_size = size.small)
            r := 1
            f_row(dash, r, "Lock", i_lockSignal ? "ACTIVE" : "OFF", i_lockSignal ? C_RES : C_DASH_TXT, f_bg(r), "")
            r += 1
            int smoothExtra = i_smoothType == "None" ? 0 : i_smoothLen - 1
            int kNeed = i_stochLen + i_kSmooth - 1 + smoothExtra
            bool regimeWarm = na(stochK) or na(trendMaVal)
            string regimeTip = str.format("Shows — until the bars needed for the Stochastic and the trend average have filled: {0} bars.", math.max(kNeed, i_trendLen))
            f_row(dash, r, "Regime", regimeWarm ? "—" : regimeState == 1 ? "Bullish" : regimeState == -1 ? "Bearish" : "Neutral", regimeWarm ? C_DASH_TXT : regimeState == 1 ? C_SUP : regimeState == -1 ? C_RES : C_DASH_TXT, f_bg(r), regimeTip)
            r += 1
            string kTip = str.format("Shows — until {0} bars have filled: the Stochastic range and the %K smoothing need {1} bars, the trend average needs {2}.", math.max(kNeed, i_trendLen), i_stochLen + i_kSmooth - 1, i_trendLen) + (i_smoothType == "None" ? "" : str.format(" The {0} adaptive smoothing needs {1} more bars on top of that chain.", i_smoothType, smoothExtra))
            f_row(dash, r, "Stochastic %K", na(stochK) ? "—" : f_bar(stochK, 100.0), na(stochK) ? C_DASH_TXT : f_barColor(stochK / 100), f_bg(r), kTip)
            r += 1
            f_row(dash, r, "Bull Range", str.tostring(bullLo) + "–" + str.tostring(bullHi), C_DASH_TXT, f_bg(r), "")
            r += 1
            f_row(dash, r, "Bear Range", str.tostring(bearLo) + "–" + str.tostring(bearHi), C_DASH_TXT, f_bg(r), "")
            r += 1
            f_row(dash, r, "Trend", trendUp ? "Up" : trendDown ? "Down" : "—", trendUp ? C_SUP : trendDown ? C_RES : C_DASH_TXT, f_bg(r), "")
            r += 1
            f_row(dash, r, "ADX Strength", na(adxVal) ? "—" : f_bar(adxVal, 100.0), na(adxVal) ? C_DASH_TXT : f_barColor(adxVal / 100), f_bg(r), "")
            r += 1
            if i_useAdx
                f_row(dash, r, "Chop Filter", na(adxVal) ? "—" : chopOk ? "Pass" : "Blocked", na(adxVal) ? C_DASH_TXT : chopOk ? C_SUP : C_RES, f_bg(r), "")
                r += 1
            if i_useHtf
                string htfTip = "Regime read on " + f_tf(i_htfTF) + ", last completed bar."
                if htfSkipped
                    f_row(dash, r, "HTF Regime", "Skipped", C_DASH_TXT, C_WARN, "The HTF timeframe is lower than the chart timeframe, so the filter is skipped.")
                else
                    f_row(dash, r, "HTF Regime", na(htfState) ? "—" : htfState == 1 ? "Bullish" : htfState == -1 ? "Bearish" : "Neutral", htfState == 1 ? C_SUP : htfState == -1 ? C_RES : C_DASH_TXT, f_bg(r), htfTip)
                r += 1
            if i_smoothType != "None"
                f_row(dash, r, "Adaptive Smoothing", i_smoothType + " · " + str.tostring(i_smoothLen), C_DASH_TXT, f_bg(r), "")
                r += 1
            int confCnt = bullRaw ? bullCnt : bearRaw ? bearCnt : 0
            f_row(dash, r, "Confirm Bars", str.tostring(math.min(confCnt, i_confirmBars)) + " / " + str.tostring(i_confirmBars), C_DASH_TXT, f_bg(r), str.format("The count restarts whenever the raw regime breaks; after each restart a regime needs {0} consecutive bars.", i_confirmBars))
            r += 1
            f_row(dash, r, "ATR Value", na(atrVal) ? "—" : str.tostring(atrVal, format.mintick), C_DASH_TXT, f_bg(r), "")
            r += 1
            string statusTxt = tradeDir == 0 ? "—" : slHit ? "Stopped" : tp3Hit ? "Targets Done" : tradeDir == 1 ? "Long Open" : "Short Open"
            color statusClr = tradeDir == 0 ? C_DASH_TXT : slHit ? C_RES : tp3Hit ? C_SUP : tradeDir == 1 ? C_SUP : C_RES
            f_row(dash, r, "Trade", statusTxt, statusClr, f_bg(r), "")
            r += 1
            f_row(dash, r, "Entry", tradeDir == 0 ? "—" : str.tostring(tradeEntry, format.mintick), C_DASH_TXT, f_bg(r), "")
            r += 1
            f_row(dash, r, "Stop", tradeDir == 0 ? "—" : str.tostring(tradeSl, format.mintick) + (slHit ? " ✓" : ""), slHit ? C_RES : C_DASH_TXT, f_bg(r), "")
            r += 1
            f_row(dash, r, "TP1", tradeDir == 0 ? "—" : str.tostring(tradeTp1, format.mintick) + (tp1Hit ? " ✓" : ""), tp1Hit ? C_SUP : C_DASH_TXT, f_bg(r), "")
            r += 1
            f_row(dash, r, "TP2", tradeDir == 0 ? "—" : str.tostring(tradeTp2, format.mintick) + (tp2Hit ? " ✓" : ""), tp2Hit ? C_SUP : C_DASH_TXT, f_bg(r), "")
            r += 1
            f_row(dash, r, "TP3", tradeDir == 0 ? "—" : str.tostring(tradeTp3, format.mintick) + (tp3Hit ? " ✓" : ""), tp3Hit ? C_SUP : C_DASH_TXT, f_bg(r), "")
            r += 1
        if i_useHtf and htfSkipped and not i_showDash
            f_row(dash, r, "HTF Regime", "Skipped", C_DASH_TXT, C_WARN, "The HTF timeframe is lower than the chart timeframe, so the filter is skipped.")
            r += 1
        bool tpReordered = tpM1 != i_tp1Mult or tpM2 != i_tp2Mult or tpM3 != i_tp3Mult
        if tpReordered
            f_row(dash, r, "Targets", "Reordered", C_DASH_TXT, C_WARN, "The target multiples were not in increasing order and were sorted nearest to farthest.")
            r += 1
    else
        table.cell(notice, 0, 0, "This indicator runs only on standard charts.", text_color = #FF0000, bgcolor = #2A2E39, text_size = size.large, text_formatting = text.format_bold)
        table.cell(notice, 0, 1, "Heikin Ashi, Renko, Kagi, Point & Figure, Range and Line Break\nshow synthetic prices. Switch to Candles.", text_color = #FF0000, bgcolor = #2A2E39, text_size = size.normal, text_formatting = text.format_bold)
````
