# Golden Cross Chob Zone

- url: https://www.tradingview.com/script/RNmUPhjL-Golden-Cross-Chob-Zone/
- type: indicator
- pine_id: PUB;8f36d4401ee3456e83d8dc49b7316589
- version: 1.0

## Description

Golden Cross Chob Zone

Golden Cross Chob Zone is a visual trend-following indicator designed to help traders study bullish trend regimes using EMA 50, EMA 200, Chop Zone trend strength, pullback behavior, and structured visual risk references.

The script combines:

* EMA 50 and EMA 200 regime analysis
* Golden Cross and Death Cross detection
* Chop Zone trend-strength coloring
* Sideways / no-trade filtering
* Multiple bullish entry-event types
* Visual Entry / Stop / Target reference lines
* EMA 200 exit logic
* Compact labels with detailed tooltips
* Dashboard status and event counters
* Alert conditions for key events

This script is an indicator, not a strategy. It does not place orders, does not execute trades, and does not produce TradingView Strategy Tester backtest results. The visual BUY, TP, SL, and EMA200 EXIT labels are chart-analysis events only. They are intended to help users study how the selected rules behave on the chart, not to guarantee performance or provide financial advice.

Important note about signals and performance

Golden Cross Chob Zone does not guarantee profitable trades.

The BUY labels are not automatic trading recommendations. They mark technical conditions where the script detected one of its bullish entry-event rules.

The TP HIT, SL HIT, EMA200 EXIT, and DC EXIT labels are visual tracking references only. They are not broker fills, not strategy orders, and not official backtest results.

The dashboard statistics are simple event counters based on the script’s visual tracking logic. They should not be interpreted as verified strategy performance, win rate, or realistic trading results.

Users should combine this tool with their own analysis, risk management, position sizing, and market context.

Core idea

The main idea of this indicator is to detect bullish market conditions where EMA 50 is above EMA 200, then look for structured bullish continuation events such as:

* Golden Cross breakout
* EMA 50 pullback confirmation
* EMA 50 bounce
* EMA 50 reclaim

The script also uses Chop Zone coloring to estimate whether the trend environment is strong, weak, choppy, or bearish. A sideways / no-trade filter can block normal BUY events when the market is too flat, too compressed, or price is not clearly above EMA 200.

Main components

1. EMA 50 and EMA 200 trend regime

The script uses two exponential moving averages:

Fast EMA
Default: EMA 50

Slow EMA
Default: EMA 200

The Fast EMA is used for pullbacks, bounces, reclaims, and Golden Cross entries.

The Slow EMA is used as the main regime filter and as an optional dynamic exit reference.

Bullish regime

A bullish regime exists when EMA 50 is above EMA 200.

This is the script’s most important directional filter. The script is designed mainly for long-side trend analysis.

Golden Cross

A Golden Cross occurs when the Fast EMA crosses above the Slow EMA.

The script can mark this event with a GC label.

Death Cross

A Death Cross occurs when the Fast EMA crosses below the Slow EMA.

The script can mark this event with a DC label.

Important: GC and DC labels are moving-average structure events. They are not guaranteed buy or sell signals.

2. EMA regime fill

The script can shade the area between EMA 50 and EMA 200.

Green fill
Fast EMA is above Slow EMA.

Red fill
Fast EMA is below Slow EMA.

This helps users quickly identify whether the chart is in a bullish or bearish EMA regime.

3. Chop Zone filter

The Chop Zone section estimates the slope strength of a selected EMA by measuring its angle relative to the recent price range.

The script calculates:

* a recent high-low range,
* an EMA slope,
* a normalized slope angle,
* a color grade based on the slope direction and strength.

The Chop Zone grade is then translated into color categories.

Positive Chop Zone grades

Turquoise
Strong upward trend condition.

Dark green
Clear upward trend condition.

Pale green
Mild upward trend condition.

Teal
Weak upward condition.

Neutral / yellow

Yellow
Choppy or neutral slope condition.

Negative Chop Zone grades

Light orange
Weak downward condition.

Orange
Mild downward condition.

Pink
Clear downward condition.

Dark red
Strong downward condition.

The Chop Zone is used as a trend-quality filter for normal BUY signals. Users can choose the minimum Chop Zone grade required to allow buys.

Minimum Grade To Allow Buys

Any green
Allows any positive green / teal condition.

Pale green or better
Requires a stronger positive Chop Zone reading.

Dark green or better
Requires a clear upward trend condition.

Turquoise only
Requires the strongest upward Chop Zone condition.

4. Chop Zone strip

The script can plot a small colored strip at the bottom of the price pane.

Each square represents the Chop Zone color for that bar.

This gives a compact visual reading of trend strength and choppiness without needing a separate pane.

5. Candle coloring by Chop Zone

The script can color price candles using the Chop Zone colors.

This helps the user visually connect candle movement with the current trend-strength classification.

Candle coloring is visual context only. It is not a standalone entry or exit signal.

Entry logic

The script supports several bullish entry-event types.

A BUY label can appear only when the script’s selected rules are met. By default, the logic is long-side focused and requires EMA 50 to be above EMA 200, except that Golden Cross breakout has its own optional filter settings.

1. Golden Cross Breakout Entry

The Golden Cross breakout entry is designed to identify a bullish breakout condition on the bar where EMA 50 crosses above EMA 200.

A GC breakout BUY can occur when:

* Golden Cross happens,
* EMA 50 is above EMA 200,
* close is above EMA 50,
* close is above EMA 200,
* candle is bullish,
* optional Chop Zone condition passes,
* optional sideways filter condition passes.

This entry type is displayed as:

GC BREAKOUT

Important: This is not a guaranteed breakout signal. It only marks that the selected Golden Cross breakout conditions were met.

2. Classic Pullback Entry

The classic pullback logic waits for price to touch or come close to EMA 50, then requires a bullish confirmation candle within a selected number of bars.

A classic pullback BUY can occur when:

* EMA 50 is above EMA 200,
* Chop Zone filter allows buys,
* price touches or nearly touches EMA 50,
* confirmation candle appears within the selected confirmation window,
* candle closes above EMA 50,
* optional prior-high confirmation passes.

This entry type is displayed as:

PULLBACK

3. EMA 50 Bounce Entry

The EMA 50 bounce entry is a more direct bounce condition.

A bounce BUY can occur when:

* EMA 50 is above EMA 200,
* Chop Zone filter allows buys,
* candle is bullish,
* close is above EMA 50,
* low touches or nearly touches EMA 50.

This entry type is displayed as:

EMA50 BOUNCE

4. EMA 50 Reclaim Entry

The EMA 50 reclaim entry looks for price recovering back above EMA 50.

A reclaim BUY can occur when:

* EMA 50 is above EMA 200,
* Chop Zone filter allows buys,
* candle is bullish,
* close is above EMA 50,
* previous close was at or below EMA 50.

This entry type is displayed as:

EMA50 RECLAIM

5. One open signal at a time

The script includes an option called:

Only One Open Signal At A Time

When enabled, the script does not print a new BUY signal while a previous signal is still being visually tracked by the Entry / SL / TP logic.

This helps reduce repeated labels in the same open setup.

Sideways / no-trade filter

The script includes a market filter designed to reduce normal BUY events in sideways or unclear conditions.

The sideways filter can check:

* EMA 50 / EMA 200 spread,
* EMA 50 slope,
* EMA 200 slope,
* price position relative to EMA 200,
* cooldown after previous exit.

The filter is designed to block normal BUY signals when market conditions are too flat, compressed, or unclear.

Important: The Golden Cross breakout entry can be allowed separately from the normal sideways filter, depending on the user settings. This is useful when the user wants to observe the first strong breakout immediately after a Golden Cross.

Filter elements

Minimum EMA50-EMA200 Spread %

Measures the distance between EMA 50 and EMA 200 as a percentage of price.

Higher values reduce signals in sideways markets.

EMA Slope Lookback

Defines how many bars are used to check if EMA 50 or EMA 200 is rising.

Require EMA 50 Slope Up

When enabled, normal BUY events require EMA 50 to be rising.

Require EMA 200 Slope Up

When enabled, normal BUY events require EMA 200 to be rising.

Require Price Above EMA 200

When enabled, normal BUY events require close to be above EMA 200.

Cooldown After Exit

Blocks new normal BUY events for a selected number of bars after TP, SL, or EMA200 exit.

This is intended to reduce repeated entries after an exit, especially in sideways markets.

Stop / exit and target logic

The script includes visual reference levels for Entry, Stop / Exit, and Target.

These levels are not strategy orders. They are chart references only.

Stop / Exit Mode

The script supports three stop / exit modes:

1. EMA 200 Break Exit

This mode uses the current EMA 200 as a dynamic exit reference.

The exit can trigger when:

* low touches EMA 200, or
* close falls below EMA 200,

depending on the selected EMA 200 break trigger.

This mode is dynamic because the EMA 200 changes as new bars form.

2. Fixed EMA 200 at Entry

This mode freezes the stop reference at the EMA 200 value on the BUY signal bar.

Unlike the dynamic EMA 200 exit, this reference does not move after entry.

3. Fixed Pullback Low

This mode places the stop reference below the recent pullback low.

The pullback low is calculated using the selected lookback period.

SL Buffer

The script allows an optional ATR-based buffer under the chosen stop anchor.

A buffer of 0.00 uses the stop anchor directly.

Increasing the value places the fixed stop reference farther away from the stop anchor.

Take-profit logic

The take-profit level is based on prior swing-high structure.

The script first looks for the highest high over the selected swing-high lookback period before the signal bar.

If that swing-high target is not available, is below entry, or gives too little reward-to-risk, the script uses a fallback R-multiple target.

Target: Swing-High Lookback

Defines how far back the script looks for a prior swing-high target.

Fallback R Multiple

Defines the fallback target based on risk distance.

Minimum Acceptable Target RR

If the prior swing-high target gives less than this minimum RR, the script uses the fallback R target instead.

Visual lines

When enabled, the script can draw:

Entry line
A dashed reference at the BUY close price.

SL / exit reference line
A red reference line based on the selected stop / exit mode.

TP line
A green reference line based on the selected target logic.

If EMA 200 Break Exit is used, the SL reference line can follow the EMA 200 dynamically.

Labels

BUY label

The BUY label appears when one of the selected entry-event rules is triggered.

If compact labels are enabled, the label stays small and the full details are placed in the tooltip.

The BUY tooltip can include:

* entry type,
* entry price,
* reference SL,
* target,
* RR,
* target mode,
* exit mode,
* EMA 50 / EMA 200 regime,
* EMA spread,
* filter status,
* cooldown status,
* Golden Cross breakout status,
* Chop Zone grade.

TP HIT label

The TP HIT label appears when price reaches the visual take-profit reference.

This label is a visual tracking event only. It is not a broker fill or a verified backtest result.

SL HIT label

The SL HIT label appears when the fixed stop reference is touched.

This applies when the selected mode uses a fixed stop reference.

EMA200 EXIT label

The EMA200 EXIT label appears when the dynamic EMA 200 exit condition is triggered.

Depending on settings, this can happen when:

* low touches EMA 200, or
* close falls below EMA 200.

DC EXIT label

The DC EXIT label can appear when a Death Cross occurs while a tracked signal is open and the selected exit logic allows that condition.

This is a moving-average structure exit event, not a strategy order.

Label spacing

The script places labels using ATR-based spacing so they are not directly attached to candles.

Label Distance From Candles controls how far labels are placed vertically away from price bars.

Dashboard

The dashboard summarizes the current condition of the indicator.

Dashboard fields

Regime

Shows whether the EMA structure is bullish or bearish.

BULL
EMA 50 is above EMA 200.

BEAR
EMA 50 is below EMA 200.

The dashboard can also show how many bars have passed since the last Golden Cross or Death Cross.

Chop Zone

Shows the current Chop Zone condition, such as:

* STRONG UP
* TREND UP
* MILD UP
* WEAK UP
* CHOP
* WEAK DOWN
* MILD DOWN
* TREND DOWN
* STRONG DOWN

Filter

Shows whether the normal market filter is allowing signals or blocking them.

OK
Normal market filter conditions are acceptable.

NO TRADE
Normal market filter is blocking normal BUY events.

The dashboard also shows EMA spread percentage.

Setup

Shows the current setup state, such as:

SIGNAL OPEN
A visual signal is currently being tracked.

COOLDOWN
New normal signals are blocked temporarily after an exit.

GC BREAKOUT READY
Golden Cross breakout conditions are present.

NO TRADE
Market filter is blocking normal entries.

PULLBACK ARMED
Price has touched the EMA 50 pullback zone and is waiting for confirmation.

WAITING PULLBACK
Bullish regime exists, but no valid entry event has triggered.

STAND ASIDE
The EMA regime is not bullish.

Open

Shows current open visual tracking references:

* Entry
* SL / exit reference
* TP

Stats

Shows simple event counters:

* total signals,
* wins counted by TP events,
* losses counted by SL / exit events,
* TP-rate based on the script’s internal visual events.

Important: These are not official Strategy Tester results and should not be presented as backtesting performance. They are simple chart-event counters for study and comparison only.

Alerts

The script includes alert conditions for:

Golden Cross

Triggered when EMA 50 crosses above EMA 200.

GC Breakout BUY

Triggered when the Golden Cross breakout entry conditions are met.

Death Cross

Triggered when EMA 50 crosses below EMA 200.

Pullback Touch

Triggered when price touches or approaches the EMA 50 pullback zone.

BUY Signal

Triggered when a selected BUY event occurs.

Chop Zone -> Green

Triggered when Chop Zone shifts into a positive / green condition.

Chop Zone -> Red

Triggered when Chop Zone shifts into a negative / red condition.

TP Hit

Triggered when the visual take-profit reference is reached.

Stop / EMA200 Exit

Triggered when the stop reference or EMA 200 exit condition is reached.

Alerts are notifications only. They do not instruct the user to buy or sell.

Settings explained

[1] Trend EMAs

Fast EMA Length
Sets the fast EMA. Default is EMA 50.

Slow EMA Length
Sets the slow EMA. Default is EMA 200.

Fill Between EMAs
Shows or hides the colored area between the two EMAs.

[2] Chop Zone Filter

Range Lookback
Defines the range used to normalize the EMA slope.

Slope EMA Length
Defines the EMA used for the Chop Zone slope calculation.

Minimum Grade To Allow Buys
Defines how strong the Chop Zone must be before normal BUY events are allowed.

Show Chop Zone Strip
Shows or hides the colored strip at the bottom of the price pane.

Color Price Bars By Chop Zone
Colors candles using the Chop Zone condition.

[3] Entry Logic

Allow Golden Cross Breakout Entry
Allows a BUY event on the Golden Cross bar if the breakout conditions are met.

GC Breakout Requires Green Chop Zone
Requires Chop Zone to be green for Golden Cross breakout entries.

Fast-EMA Touch Tolerance (%)
Allows a candle low to come close to EMA 50 instead of requiring an exact touch.

Confirm Within (bars)
Defines how many bars are allowed between an EMA 50 touch and a confirmation candle.

Confirm Candle Must Close Above Prior High
Requires the confirmation candle to close above the previous bar’s high.

Allow Classic Pullback Entry
Enables the classic pullback entry-event logic.

Allow EMA 50 Bounce Entry
Enables the EMA 50 bounce entry-event logic.

Allow EMA 50 Reclaim Entry
Enables the EMA 50 reclaim entry-event logic.

Only One Open Signal At A Time
Blocks new BUY events while a previous visual signal is still open.

[4] Sideways / No-Trade Filter

Enable Sideways / No-Trade Filter
Enables or disables the normal market filter.

Apply Sideways Filter To GC Breakout
Applies the sideways filter to Golden Cross breakout entries when enabled.

Minimum EMA50-EMA200 Spread (%)
Requires a minimum distance between EMA 50 and EMA 200.

EMA Slope Lookback (bars)
Defines the slope lookback for EMA slope checks.

Require EMA 50 Slope Up
Requires EMA 50 to be rising.

Require EMA 200 Slope Up
Requires EMA 200 to be rising.

Require Price Above EMA 200
Requires close to be above EMA 200.

Cooldown After Exit (bars)
Blocks normal BUY events after an exit for the selected number of bars.

[5] Stop Loss / Target

Stop / Exit Mode
Chooses between dynamic EMA 200 exit, fixed EMA 200 at entry, or fixed pullback low.

EMA 200 Break Trigger
Chooses whether the dynamic EMA 200 exit uses a low touch or a close below EMA 200.

ATR Length
Controls the ATR used for stop buffer and label spacing.

SL Buffer (ATR multiples)
Adds an optional ATR buffer to the stop reference.

Pullback Low Lookback (bars)
Defines the lookback for the fixed pullback low stop mode.

Target: Swing-High Lookback (bars)
Defines the lookback for the prior swing-high target.

Fallback R Multiple
Defines the fallback target if the swing-high target is not usable.

Minimum Acceptable Target RR
Defines the minimum reward-to-risk required before using the swing-high target.

[6] Visuals / Dashboard

Show Dashboard
Shows or hides the dashboard.

Dashboard Position
Moves the dashboard to a selected chart corner.

Mark Golden / Death Crosses
Shows or hides GC and DC labels.

Draw Entry / SL / TP Lines
Shows or hides the visual reference lines.

Show BUY Triangle
Shows or hides the BUY triangle marker.

Use Compact Labels
Uses smaller labels with full details stored in tooltips.

Show BUY Label
Shows or hides the BUY label.

Label Distance From Candles (ATR)
Controls vertical spacing between labels and candles.

How to use this indicator

A practical workflow:

1. Check whether EMA 50 is above EMA 200.
2. Check the Chop Zone condition.
3. Check whether the dashboard says OK or NO TRADE.
4. Watch for one of the selected BUY event types.
5. Review the visual Entry, SL / exit reference, and TP reference.
6. Use the tooltip on the label for full signal details.
7. Treat all labels as chart-analysis events, not as automatic trade instructions.
8. Combine the signal event with market structure, volume, higher timeframe analysis, and risk management.

Example interpretation

If a GC BREAKOUT label appears, it means EMA 50 crossed above EMA 200 and the selected breakout conditions were met. It does not guarantee that price will continue higher.

If a PULLBACK label appears, it means price touched the EMA 50 pullback zone and then produced a bullish confirmation candle within the selected confirmation window.

If an EMA50 BOUNCE label appears, it means price touched or nearly touched EMA 50 and closed back above it with a bullish candle.

If an EMA50 RECLAIM label appears, it means price closed back above EMA 50 after previously being at or below it.

If EMA200 EXIT appears, it means the dynamic EMA 200 exit condition was triggered.

If TP HIT appears, it means price reached the visual target reference.

Important limitations

This indicator does not predict future price movement.

It does not guarantee profitable trades.

It does not place orders.

It does not produce Strategy Tester results.

BUY labels are not financial advice.

TP / SL / exit labels are not broker fills.

Dashboard stats are internal visual event counters, not verified backtest statistics.

EMA-based systems can perform poorly in choppy, sideways, or low-volume markets.

Chop Zone classification is based on slope and range normalization, not on future price prediction.

The script is designed mainly for long-side trend-following analysis.

Different symbols, markets, sessions, and timeframes may require different settings.

Users are responsible for their own trade decisions, risk management, and position sizing.

Recommended use

Golden Cross Chob Zone is best used as a decision-support and chart-analysis tool for traders who study:

* Golden Cross / Death Cross structure,
* EMA 50 and EMA 200 trend regimes,
* EMA pullbacks,
* EMA 50 bounces,
* EMA 50 reclaim events,
* trend strength and choppiness,
* visual risk references,
* long-side trend continuation conditions.

It should be used as one part of a broader trading process, not as a standalone trading system.

Originality and purpose

Golden Cross Chob Zone combines several visual and analytical components into one workflow:

* EMA 50 / EMA 200 regime detection,
* Golden Cross breakout logic,
* Chop Zone trend-strength filter,
* pullback / bounce / reclaim entry-event logic,
* sideways market filtering,
* visual Entry / SL / TP references,
* dynamic EMA 200 exit option,
* compact labels with detailed tooltips,
* dashboard state monitoring,
* alert conditions for key events.

The purpose is to help users study bullish trend-continuation conditions with clearer visual context and fewer signals during weak or sideways conditions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ADXAE

//@version=6
// =============================================================================
// Golden Cross Chob Zone
// =============================================================================

indicator("Golden Cross Chob Zone", shorttitle="GC Chob Zone", overlay=true,
     max_lines_count=500, max_labels_count=500)

// =============================================================================
// INPUTS
// =============================================================================

grpTrend  = "[1] Trend EMAs"
grpCZ     = "[2] Chop Zone Filter"
grpEntry  = "[3] Entry Logic"
grpFilter = "[4] Sideways / No-Trade Filter"
grpRisk   = "[5] Stop Loss / Target"
grpVis    = "[6] Visuals / Dashboard"

// --- [1] Trend EMAs
fastLen = input.int(50, "Fast EMA Length", minval=2, group=grpTrend,
     tooltip="Fast EMA used for pullbacks, bounces, reclaims and Golden Cross entries. Default is EMA 50.")

slowLen = input.int(200, "Slow EMA Length", minval=5, group=grpTrend,
     tooltip="Slow EMA used for the main regime filter and EMA 200 break exit. Default is EMA 200.")

showRegimeFill = input.bool(true, "Fill Between EMAs", group=grpTrend,
     tooltip="Shade the area between the two EMAs: green while Fast EMA is above Slow EMA, red otherwise.")

// --- [2] Chop Zone
czRangeLen = input.int(30, "Range Lookback", minval=5, maxval=200, group=grpCZ,
     tooltip="Lookback used to normalize the EMA slope by the recent high-low range.")

czEmaLen = input.int(34, "Slope EMA Length", minval=2, maxval=200, group=grpCZ,
     tooltip="The EMA whose slope angle is measured for the Chop Zone calculation.")

czMinGrade = input.string("Any green", "Minimum Grade To Allow Buys",
     options=["Any green", "Pale green or better", "Dark green or better", "Turquoise only"], group=grpCZ,
     tooltip="Controls how strong the Chop Zone must be before normal BUY signals are allowed.")

showCZStrip = input.bool(true, "Show Chop Zone Strip", group=grpCZ,
     tooltip="Paints one square per bar at the bottom of the price pane using the Chop Zone colors.")

colorBarsCZ = input.bool(true, "Color Price Bars By Chop Zone", group=grpCZ,
     tooltip="Paints the candles with the Chop Zone color. Enabled by default.")

// --- [3] Entry Logic
allowGcBreakout = input.bool(true, "Allow Golden Cross Breakout Entry", group=grpEntry,
     tooltip="When ON, the script gives a BUY immediately on the Golden Cross bar if price closes above both EMA 50 and EMA 200 with a bullish candle.")

gcNeedsChopGreen = input.bool(false, "GC Breakout Requires Green Chop Zone", group=grpEntry,
     tooltip="When ON, the Golden Cross breakout entry also requires the Chop Zone to be green. When OFF, the GC breakout is allowed based on the cross and price structure only.")

touchTolPct = input.float(0.15, "Fast-EMA Touch Tolerance (%)", minval=0.0, maxval=3.0, step=0.05, group=grpEntry,
     tooltip="The bar low only needs to come within this percentage above the Fast EMA to count as a touch or bounce.")

confirmBars = input.int(5, "Confirm Within (bars)", minval=1, maxval=30, group=grpEntry,
     tooltip="For classic pullback entries, the bullish confirmation candle must appear within this many bars of the touch.")

needPrevHighBreak = input.bool(false, "Confirm Candle Must Close Above Prior High", group=grpEntry,
     tooltip="Stricter confirmation: the green candle must also close above the previous bar's high.")

allowClassicPullback = input.bool(true, "Allow Classic Pullback Entry", group=grpEntry,
     tooltip="Original logic: touch the EMA 50 zone first, then confirm with a green candle above EMA 50. Works only when EMA 50 is above EMA 200 and the market filter allows trading.")

allowEmaBounce = input.bool(true, "Allow EMA 50 Bounce Entry", group=grpEntry,
     tooltip="BUY when price touches or nearly touches EMA 50 and closes back above it with a green candle. Works only when EMA 50 is above EMA 200 and the market filter allows trading.")

allowEmaReclaim = input.bool(true, "Allow EMA 50 Reclaim Entry", group=grpEntry,
     tooltip="BUY when price closes back above EMA 50 after the previous close was at or below EMA 50. Works only when EMA 50 is above EMA 200 and the market filter allows trading.")

onePosition = input.bool(true, "Only One Open Signal At A Time", group=grpEntry,
     tooltip="When ON, no new BUY can fire while a previous signal's SL/TP tracking is still open.")

// --- [4] Sideways / No-Trade Filter
useSidewaysFilter = input.bool(true, "Enable Sideways / No-Trade Filter", group=grpFilter,
     tooltip="When ON, the script blocks normal BUY signals when EMA 50 and EMA 200 are too close, flat, or price is not clearly above EMA 200. Golden Cross breakout can still be allowed separately.")

applyFilterToGcBreakout = input.bool(false, "Apply Sideways Filter To GC Breakout", group=grpFilter,
     tooltip="When OFF, Golden Cross breakout entries can appear even if the normal market filter says NO TRADE. This helps avoid missing the first strong breakout after GC.")

minEmaSpreadPct = input.float(1.00, "Minimum EMA50-EMA200 Spread (%)", minval=0.0, maxval=10.0, step=0.10, group=grpFilter,
     tooltip="Minimum distance between EMA 50 and EMA 200 as a percent of price. Higher values reduce signals in sideways markets.")

slopeLookback = input.int(5, "EMA Slope Lookback (bars)", minval=1, maxval=50, group=grpFilter,
     tooltip="Lookback used to confirm that EMA 50 and EMA 200 are not flat or turning down.")

needFastSlopeUp = input.bool(true, "Require EMA 50 Slope Up", group=grpFilter,
     tooltip="When ON, normal BUY signals are allowed only if EMA 50 is rising over the selected slope lookback.")

needSlowSlopeUp = input.bool(false, "Require EMA 200 Slope Up", group=grpFilter,
     tooltip="When ON, normal BUY signals are allowed only if EMA 200 is rising over the selected slope lookback. This is stricter and may reduce early trend signals.")

needPriceAboveEma200 = input.bool(true, "Require Price Above EMA 200", group=grpFilter,
     tooltip="When ON, normal BUY signals are allowed only if close is above EMA 200.")

cooldownAfterExit = input.int(10, "Cooldown After Exit (bars)", minval=0, maxval=100, group=grpFilter,
     tooltip="Blocks new normal BUY signals for this many bars after TP / SL / EMA200 exit. Helps reduce repeated signals in sideways markets.")

// --- [5] Stop / Target
exitMode = input.string("EMA 200 Break Exit", "Stop / Exit Mode",
     options=["EMA 200 Break Exit", "Fixed EMA 200 at Entry", "Fixed Pullback Low"], group=grpRisk,
     tooltip="'EMA 200 Break Exit' exits when price touches or breaks the current EMA 200 based on the selected trigger. 'Fixed EMA 200 at Entry' freezes the stop at EMA 200 on the signal bar. 'Fixed Pullback Low' freezes the stop under the recent pullback low.")

emaBreakType = input.string("Low Touches EMA 200", "EMA 200 Break Trigger",
     options=["Low Touches EMA 200", "Close Below EMA 200"], group=grpRisk,
     tooltip="Used only with EMA 200 Break Exit. Low Touches EMA 200 exits faster at the first touch/break. Close Below EMA 200 is cleaner but may exit later.")

atrLen = input.int(14, "ATR Length", minval=1, maxval=100, group=grpRisk,
     tooltip="ATR length used for optional SL buffer and label spacing.")

slAtrBuf = input.float(0.00, "SL Buffer (ATR multiples)", minval=0.0, maxval=3.0, step=0.05, group=grpRisk,
     tooltip="0.00 means the stop/exit anchor is used directly. Increase it to place the fixed stop farther below the chosen anchor.")

pullLowLen = input.int(10, "Pullback Low Lookback (bars)", minval=2, maxval=100, group=grpRisk,
     tooltip="Used only when Stop / Exit Mode is Fixed Pullback Low.")

swingLen = input.int(50, "Target: Swing-High Lookback (bars)", minval=5, maxval=300, group=grpRisk,
     tooltip="The take-profit uses the highest high of this many bars before the signal bar.")

fallbackRR = input.float(2.0, "Fallback R Multiple", minval=0.5, maxval=10.0, step=0.5, group=grpRisk,
     tooltip="If the prior swing-high target is missing, below entry, or too close, TP falls back to entry plus this many R.")

minTargetRR = input.float(1.20, "Minimum Acceptable Target RR", minval=0.2, maxval=5.0, step=0.1, group=grpRisk,
     tooltip="If the prior swing-high target gives less than this RR, the script uses the Fallback R target instead.")

// --- [6] Visuals
showDash = input.bool(true, "Show Dashboard", group=grpVis)

dashPosOpt = input.string("Top right", "Dashboard Position",
     options=["Top right", "Top left", "Bottom right", "Bottom left"], group=grpVis)

showGCDC = input.bool(true, "Mark Golden / Death Crosses", group=grpVis)

showTradeLines = input.bool(true, "Draw Entry / SL / TP Lines", group=grpVis)

showBuyMarker = input.bool(true, "Show BUY Triangle", group=grpVis)

showCompactLabels = input.bool(true, "Use Compact Labels", group=grpVis,
     tooltip="When ON, BUY/SL/TP labels stay small and full details are stored in tooltip.")

showBuyDetail = input.bool(true, "Show BUY Label", group=grpVis,
     tooltip="Shows a BUY label. If Compact Labels is ON, full trade details are available in tooltip.")

labelAtrPad = input.float(2.50, "Label Distance From Candles (ATR)", minval=0.2, maxval=8.0, step=0.1, group=grpVis,
     tooltip="Controls how far labels are placed vertically away from candles using ATR. Labels are not shifted horizontally, so they remain on the true signal bar.")

// =============================================================================
// COLORS
// =============================================================================

COL_TURQ = #26C6DA
COL_DGRN = #43A047
COL_PGRN = #A5D6A7
COL_TEAL = #009688
COL_YELL = #FDD835
COL_LORG = #FFB74D
COL_ORNG = #FF6D00
COL_PINK = #E91E63
COL_DRED = #D50000

COL_FAST = #1565C0
COL_SLOW = #C62828

// =============================================================================
// CORE SERIES
// =============================================================================

emaF   = ta.ema(close, fastLen)
emaS   = ta.ema(close, slowLen)
atrVal = ta.atr(atrLen)

goldenCross = ta.crossover(emaF, emaS)
deathCross  = ta.crossunder(emaF, emaS)
bullRegime  = emaF > emaS

pullbackLow    = ta.lowest(low, pullLowLen)
priorSwingHigh = ta.highest(high, swingLen)[1]

// =============================================================================
// CHOP ZONE
// =============================================================================

czHH   = ta.highest(high, czRangeLen)
czLL   = ta.lowest(low, czRangeLen)
czSpan = czHH > czLL ? 25.0 / (czHH - czLL) * czLL : na
czEma  = ta.ema(close, czEmaLen)
czAvg  = hl2

czY2 = not na(czSpan) and czAvg != 0 ? (czEma[1] - czEma) / czAvg * czSpan : na
czC  = not na(czY2) ? math.sqrt(1.0 + czY2 * czY2) : na
czAngAbs = not na(czC) ? math.round(180.0 * math.acos(1.0 / czC) / math.pi) : na
emaAngle = na(czAngAbs) ? na : (czY2 > 0 ? -czAngAbs : czAngAbs)

czGrade = na(emaAngle) ? 0 :
     emaAngle >=  5    ?  4 :
     emaAngle >=  3.57 ?  3 :
     emaAngle >=  2.14 ?  2 :
     emaAngle >=  0.71 ?  1 :
     emaAngle <= -5    ? -4 :
     emaAngle <= -3.57 ? -3 :
     emaAngle <= -2.14 ? -2 :
     emaAngle <= -0.71 ? -1 : 0

czColor = czGrade ==  4 ? COL_TURQ :
     czGrade ==  3 ? COL_DGRN :
     czGrade ==  2 ? COL_PGRN :
     czGrade ==  1 ? COL_TEAL :
     czGrade == -1 ? COL_LORG :
     czGrade == -2 ? COL_ORNG :
     czGrade == -3 ? COL_PINK :
     czGrade == -4 ? COL_DRED : COL_YELL

czMinGradeNum = czMinGrade == "Turquoise only" ? 4 :
     czMinGrade == "Dark green or better" ? 3 :
     czMinGrade == "Pale green or better" ? 2 : 1

czBullOK = czGrade >= czMinGradeNum

czTurnedGreen = czGrade >= 1 and czGrade[1] < 1
czTurnedRed   = czGrade <= -1 and czGrade[1] > -1

// =============================================================================
// SIDEWAYS / NO-TRADE FILTER
// =============================================================================

emaSpreadPct = math.abs(emaF - emaS) / close * 100.0
trendSpreadOK = emaSpreadPct >= minEmaSpreadPct

ema50SlopeOK = emaF > emaF[slopeLookback]
ema200SlopeOK = emaS >= emaS[slopeLookback]
priceAbove200OK = close > emaS

marketFilterOK = not useSidewaysFilter or (
     trendSpreadOK and
     (not needFastSlopeUp or ema50SlopeOK) and
     (not needSlowSlopeUp or ema200SlopeOK) and
     (not needPriceAboveEma200 or priceAbove200OK)
)

// =============================================================================
// LABEL DISTANCE
// =============================================================================

buyLabelPad   = atrVal * labelAtrPad
exitLabelPad  = atrVal * labelAtrPad
crossLabelPad = atrVal * 0.55

// =============================================================================
// ENTRY STATE MACHINE
// =============================================================================

var bool armed = false
var int  touchBar = na

touch   = bullRegime and low <= emaF * (1.0 + touchTolPct / 100.0) and close > emaS
invalid = not bullRegime or close < emaS

if invalid
    armed := false

if touch
    armed := true
    touchBar := bar_index

confirmCandle = close > open and close > emaF and (not needPrevHighBreak or close > high[1])
windowOK      = armed and not na(touchBar) and (bar_index - touchBar) <= confirmBars

classicPullbackSignal = allowClassicPullback and bullRegime and czBullOK and windowOK and confirmCandle

ema50BounceSignal = allowEmaBounce and bullRegime and czBullOK and close > open and close > emaF and low <= emaF * (1.0 + touchTolPct / 100.0)

ema50ReclaimSignal = allowEmaReclaim and bullRegime and czBullOK and close > open and close > emaF and close[1] <= emaF[1]

gcBreakoutChopOK = gcNeedsChopGreen ? czBullOK : true
gcBreakoutFilterOK = applyFilterToGcBreakout ? marketFilterOK : true

gcBreakoutSignal =
     allowGcBreakout and
     goldenCross and
     bullRegime and
     close > emaF and
     close > emaS and
     close > open and
     gcBreakoutChopOK and
     gcBreakoutFilterOK

normalEntryTriggerOK = classicPullbackSignal or ema50BounceSignal or ema50ReclaimSignal

entryTriggerOK = gcBreakoutSignal or normalEntryTriggerOK

entryType =
     gcBreakoutSignal ? "GC BREAKOUT" :
     ema50ReclaimSignal ? "EMA50 RECLAIM" :
     ema50BounceSignal  ? "EMA50 BOUNCE" :
     classicPullbackSignal ? "PULLBACK" : "ENTRY"

// =============================================================================
// SIGNAL TRACKING
// =============================================================================

var bool  tradeActive = false
var float tEntry = na
var float tSL    = na
var float tTP    = na
var int   entryBar = na
var int   lastExitBar = na

var line lnEntry = na
var line lnSL    = na
var line lnTP    = na

var int cntSignals = 0
var int cntWins    = 0
var int cntLosses  = 0

bool tpHitEvt = false
bool slHitEvt = false

dynamicEmaExit = exitMode == "EMA 200 Break Exit"

cooldownOK = na(lastExitBar) or (bar_index - lastExitBar > cooldownAfterExit)

normalBuyRaw = bullRegime and czBullOK and marketFilterOK and cooldownOK and normalEntryTriggerOK
gcBuyRaw     = bullRegime and cooldownOK and gcBreakoutSignal

buyRaw = gcBuyRaw or normalBuyRaw

// =============================================================================
// GC / DC LABELS
// =============================================================================

if showGCDC and goldenCross
    crossPriceGC = (emaF + emaS) / 2.0
    label.new(
         bar_index, crossPriceGC - crossLabelPad, "GC",
         yloc=yloc.price,
         style=label.style_label_up,
         color=color.new(COL_DGRN, 0),
         textcolor=color.white,
         size=size.small,
         tooltip="Golden Cross: Fast EMA crossed above Slow EMA")

if showGCDC and deathCross
    crossPriceDC = (emaF + emaS) / 2.0
    label.new(
         bar_index, crossPriceDC + crossLabelPad, "DC",
         yloc=yloc.price,
         style=label.style_label_down,
         color=color.new(COL_DRED, 0),
         textcolor=color.white,
         size=size.small,
         tooltip="Death Cross: Fast EMA crossed below Slow EMA")

// =============================================================================
// EXIT DETECTION
// =============================================================================

if tradeActive and not na(entryBar) and bar_index > entryBar
    barsSinceEntry = bar_index - entryBar

    currentSL = dynamicEmaExit ? emaS - slAtrBuf * atrVal : tSL

    emaBreakExit = dynamicEmaExit and (emaBreakType == "Low Touches EMA 200" ? low <= emaS : close < emaS)
    fixedSLExit  = not dynamicEmaExit and low <= tSL

    if emaBreakExit or fixedSLExit
        slHitEvt := true
        cntLosses += 1
        tradeActive := false
        lastExitBar := bar_index

        exitPrice = emaBreakExit ? emaS : tSL
        slPct = (exitPrice / tEntry - 1.0) * 100.0

        slLabelY = math.min(low, exitPrice) - exitLabelPad

        exitLabelName = emaBreakExit ? "EMA200 EXIT" : "SL HIT"

        slText = showCompactLabels ?
             exitLabelName + "\n" + str.tostring(slPct, "#.##") + "%" :
             exitLabelName + " " + str.tostring(slPct, "#.##") + "%"

        slTooltip =
             (emaBreakExit ? "EMA 200 Touch/Break Exit" : "Fixed Stop Loss Hit") +
             "\nEntry: " + str.tostring(tEntry, format.mintick) +
             "\nExit Reference: " + str.tostring(exitPrice, format.mintick) +
             "\nEMA 50: " + str.tostring(emaF, format.mintick) +
             "\nEMA 200: " + str.tostring(emaS, format.mintick) +
             "\nReference SL: " + str.tostring(currentSL, format.mintick) +
             "\nTP: " + str.tostring(tTP, format.mintick) +
             "\nResult: " + str.tostring(slPct, "#.##") + "%" +
             "\nBars since entry: " + str.tostring(barsSinceEntry)

        label.new(
             bar_index, slLabelY,
             slText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_up,
             color=color.new(COL_DRED, 10),
             textcolor=color.white,
             size=size.small,
             tooltip=slTooltip)

    else if high >= tTP
        tpHitEvt := true
        cntWins += 1
        tradeActive := false
        lastExitBar := bar_index

        tpPct = (tTP / tEntry - 1.0) * 100.0
        tpLabelY = math.max(high, tTP) + exitLabelPad

        tpText = showCompactLabels ? "TP HIT\n+" + str.tostring(tpPct, "#.##") + "%" :
             "TP HIT +" + str.tostring(tpPct, "#.##") + "%"

        tpTooltip =
             "Take Profit Hit" +
             "\nEntry: " + str.tostring(tEntry, format.mintick) +
             "\nTP: " + str.tostring(tTP, format.mintick) +
             "\nResult: +" + str.tostring(tpPct, "#.##") + "%" +
             "\nBars since entry: " + str.tostring(barsSinceEntry)

        label.new(
             bar_index, tpLabelY,
             tpText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=color.new(COL_DGRN, 10),
             textcolor=color.white,
             size=size.small,
             tooltip=tpTooltip)

    else if not dynamicEmaExit and deathCross
        exitPct = (close / tEntry - 1.0) * 100.0

        if close > tEntry
            cntWins += 1
        else
            cntLosses += 1

        tradeActive := false
        lastExitBar := bar_index

        dcExitY = high + exitLabelPad

        dcExitText = showCompactLabels ? "DC EXIT\n" + str.tostring(exitPct, "#.##") + "%" :
             "DC EXIT " + str.tostring(exitPct, "#.##") + "%"

        dcExitTooltip =
             "Death Cross Exit" +
             "\nEntry: " + str.tostring(tEntry, format.mintick) +
             "\nExit: " + str.tostring(close, format.mintick) +
             "\nResult: " + str.tostring(exitPct, "#.##") + "%"

        label.new(
             bar_index, dcExitY,
             dcExitText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_down,
             color=color.new(color.gray, 10),
             textcolor=color.white,
             size=size.small,
             tooltip=dcExitTooltip)

// =============================================================================
// NEW SIGNAL
// =============================================================================

buySignal = buyRaw and (not onePosition or not tradeActive)

if buySignal
    armed := false

    tEntry := close

    slAnchor = exitMode == "Fixed Pullback Low" ? pullbackLow : emaS
    tSL := slAnchor - slAtrBuf * atrVal

    risk = math.max(tEntry - tSL, syminfo.mintick)

    swingTP    = priorSwingHigh
    swingRR    = not na(swingTP) ? (swingTP - tEntry) / risk : na
    fallbackTP = tEntry + fallbackRR * risk

    useFallbackTP = na(swingTP) or swingTP <= tEntry or na(swingRR) or swingRR < minTargetRR
    tTP := useFallbackTP ? fallbackTP : swingTP

    entryBar := bar_index
    tradeActive := true
    cntSignals += 1

    if showTradeLines
        lnEntry := line.new(bar_index, tEntry, bar_index + 1, tEntry,
             color=color.new(color.gray, 20),
             style=line.style_dashed,
             width=1)

        lnSL := line.new(bar_index, tSL, bar_index + 1, tSL,
             color=color.new(COL_DRED, 0),
             style=dynamicEmaExit ? line.style_dotted : line.style_solid,
             width=2)

        lnTP := line.new(bar_index, tTP, bar_index + 1, tTP,
             color=color.new(COL_DGRN, 0),
             style=line.style_solid,
             width=2)

    if showBuyDetail
        rrTxt = str.tostring((tTP - tEntry) / risk, "#.##")
        tpModeTxt = useFallbackTP ? "FB" : "SW"

        buyLabelY = math.min(low, tSL) - buyLabelPad

        buyText = showCompactLabels ? "BUY\n" + entryType :
             "BUY " + str.tostring(tEntry, format.mintick) +
             "\nSL " + str.tostring(tSL, format.mintick) +
             "\nTP " + str.tostring(tTP, format.mintick) +
             "\nRR 1:" + rrTxt +
             "\n" + entryType +
             "\nTP " + tpModeTxt

        buyTooltip =
             "BUY Signal" +
             "\nType: " + entryType +
             "\nEntry: " + str.tostring(tEntry, format.mintick) +
             "\nReference SL: " + str.tostring(tSL, format.mintick) +
             "\nTP: " + str.tostring(tTP, format.mintick) +
             "\nRR: 1:" + rrTxt +
             "\nTP Mode: " + tpModeTxt +
             "\nExit Mode: " + exitMode +
             "\nEMA Break Trigger: " + emaBreakType +
             "\nEMA 50 > EMA 200: " + str.tostring(bullRegime) +
             "\nEMA Spread %: " + str.tostring(emaSpreadPct, "#.##") +
             "\nMarket Filter OK: " + str.tostring(marketFilterOK) +
             "\nCooldown OK: " + str.tostring(cooldownOK) +
             "\nGC Breakout: " + str.tostring(gcBreakoutSignal) +
             "\nChop Zone Grade: " + str.tostring(czGrade)

        label.new(
             bar_index, buyLabelY,
             buyText,
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_up,
             color=color.new(COL_TEAL, 10),
             textcolor=color.white,
             size=size.small,
             tooltip=buyTooltip)

// =============================================================================
// EXTEND OPEN TRADE LINES
// =============================================================================

if tradeActive and showTradeLines and not na(lnEntry)
    line.set_x2(lnEntry, bar_index + 1)
    line.set_x2(lnSL,    bar_index + 1)
    line.set_x2(lnTP,    bar_index + 1)

    if dynamicEmaExit
        dynamicSL = emaS - slAtrBuf * atrVal
        line.set_y1(lnSL, dynamicSL)
        line.set_y2(lnSL, dynamicSL)

// =============================================================================
// PLOTS
// =============================================================================

pFast = plot(emaF, "Fast EMA", color=COL_FAST, linewidth=2)
pSlow = plot(emaS, "Slow EMA", color=COL_SLOW, linewidth=2)

fill(pFast, pSlow,
     color=showRegimeFill ? (bullRegime ? color.new(COL_DGRN, 88) : color.new(COL_DRED, 90)) : na,
     title="Regime Fill")

plotshape(showBuyMarker and buySignal,
     title="BUY",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.new(COL_TEAL, 0),
     size=size.small)

plotshape(showCZStrip,
     title="Chop Zone Strip",
     style=shape.square,
     location=location.bottom,
     color=czColor,
     size=size.small)

barcolor(colorBarsCZ ? czColor : na, title="Chop Zone Bar Color")

// =============================================================================
// DASHBOARD
// =============================================================================

dashPos = dashPosOpt == "Top left" ? position.top_left :
     dashPosOpt == "Bottom right" ? position.bottom_right :
     dashPosOpt == "Bottom left" ? position.bottom_left : position.top_right

czName = czGrade ==  4 ? "STRONG UP" :
     czGrade ==  3 ? "TREND UP" :
     czGrade ==  2 ? "MILD UP" :
     czGrade ==  1 ? "WEAK UP" :
     czGrade == -1 ? "WEAK DOWN" :
     czGrade == -2 ? "MILD DOWN" :
     czGrade == -3 ? "TREND DOWN" :
     czGrade == -4 ? "STRONG DOWN" : "CHOP"

czTextCol = czGrade == 4 or czGrade == 2 or czGrade == 0 or czGrade == -1 ? color.black : color.white

var int lastCrossBar = na

if goldenCross or deathCross
    lastCrossBar := bar_index

var table dash = na

if showDash and barstate.islast
    if na(dash)
        dash := table.new(dashPos, 2, 7,
             bgcolor=color.new(color.black, 25),
             border_width=1,
             border_color=color.new(color.gray, 65))

        table.cell(dash, 0, 0, "GOLDEN CROSS CHOB ZONE",
             text_color=color.white,
             text_size=size.small,
             bgcolor=color.new(color.black, 0))

        table.merge_cells(dash, 0, 0, 1, 0)

    regimeTxt = (bullRegime ? "BULL" : "BEAR") + (na(lastCrossBar) ? "" : " (" + str.tostring(bar_index - lastCrossBar) + " bars)")

    table.cell(dash, 0, 1, "Regime",
         text_color=color.silver,
         text_size=size.tiny)

    table.cell(dash, 1, 1, regimeTxt,
         text_color=color.white,
         text_size=size.small,
         bgcolor=bullRegime ? color.new(COL_DGRN, 30) : color.new(COL_DRED, 30))

    table.cell(dash, 0, 2, "Chop Zone",
         text_color=color.silver,
         text_size=size.tiny)

    table.cell(dash, 1, 2, czName,
         text_color=czTextCol,
         text_size=size.small,
         bgcolor=czColor)

    filterTxt = marketFilterOK ? "OK" : "NO TRADE"

    table.cell(dash, 0, 3, "Filter",
         text_color=color.silver,
         text_size=size.tiny)

    table.cell(dash, 1, 3, filterTxt + "  Spread " + str.tostring(emaSpreadPct, "#.##") + "%",
         text_color=color.white,
         text_size=size.tiny,
         bgcolor=marketFilterOK ? color.new(COL_DGRN, 50) : color.new(COL_DRED, 35))

    setupTxt = tradeActive ? "SIGNAL OPEN" :
         not cooldownOK ? "COOLDOWN" :
         gcBreakoutSignal ? "GC BREAKOUT READY" :
         not marketFilterOK ? "NO TRADE" :
         armed ? "PULLBACK ARMED" :
         bullRegime ? "WAITING PULLBACK" : "STAND ASIDE"

    table.cell(dash, 0, 4, "Setup",
         text_color=color.silver,
         text_size=size.tiny)

    table.cell(dash, 1, 4, setupTxt,
         text_color=color.white,
         text_size=size.small)

    currentOpenSL = tradeActive ? (dynamicEmaExit ? emaS - slAtrBuf * atrVal : tSL) : na

    openTxt = tradeActive ?
         "E " + str.tostring(tEntry, format.mintick) +
         "  SL " + str.tostring(currentOpenSL, format.mintick) +
         "  TP " + str.tostring(tTP, format.mintick) : "none"

    table.cell(dash, 0, 5, "Open",
         text_color=color.silver,
         text_size=size.tiny)

    table.cell(dash, 1, 5, openTxt,
         text_color=color.white,
         text_size=size.tiny)

    closedN = cntWins + cntLosses
    hitTxt = closedN > 0 ? str.tostring(100.0 * cntWins / closedN, "#.#") + "%" : "n/a"

    statsTxt = str.tostring(cntSignals) + " sig  W:" + str.tostring(cntWins) +
         " L:" + str.tostring(cntLosses) + "  TP-rate " + hitTxt

    table.cell(dash, 0, 6, "Stats",
         text_color=color.silver,
         text_size=size.tiny)

    table.cell(dash, 1, 6, statsTxt,
         text_color=color.white,
         text_size=size.tiny)

// =============================================================================
// ALERTS
// =============================================================================

alertcondition(goldenCross, "Golden Cross",
     "Golden Cross Chob Zone: golden cross - Fast EMA crossed above Slow EMA")

alertcondition(gcBreakoutSignal, "GC Breakout BUY",
     "Golden Cross Chob Zone: BUY - Golden Cross breakout entry")

alertcondition(deathCross, "Death Cross",
     "Golden Cross Chob Zone: death cross - Fast EMA crossed below Slow EMA")

alertcondition(touch, "Pullback Touch",
     "Golden Cross Chob Zone: price touched the Fast EMA pullback zone")

alertcondition(buySignal, "BUY Signal",
     "Golden Cross Chob Zone: BUY - GC breakout or EMA50 pullback/bounce/reclaim while EMA50 is above EMA200")

alertcondition(czTurnedGreen, "Chop Zone -> Green",
     "Golden Cross Chob Zone: Chop Zone turned green")

alertcondition(czTurnedRed, "Chop Zone -> Red",
     "Golden Cross Chob Zone: Chop Zone turned red")

alertcondition(tpHitEvt, "TP Hit",
     "Golden Cross Chob Zone: take-profit level reached")

alertcondition(slHitEvt, "Stop / EMA200 Exit",
     "Golden Cross Chob Zone: stop loss or EMA 200 touch/break exit triggered")
````
