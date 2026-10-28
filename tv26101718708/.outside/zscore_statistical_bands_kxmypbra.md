# Z-Score Statistical Bands

- url: https://www.tradingview.com/script/KXMYpBRA-Z-Score-Statistical-Bands/
- type: indicator
- pine_id: PUB;2b076d902170407c93a81f7f8349354d
- version: 1.0

## Description

Z-Score Statistical Bands

1. Overview

https://www.tradingview.com/x/SVmCTuPS/

Z-Score Statistical Bands is a statistical mean-reversion indicator designed to help traders study how far a selected price series, or a pairs spread, has moved away from its rolling mean.

The script calculates and displays a Z-score oscillator with statistical bands, optional mean-reversion entry markers, exit markers, blocked setup markers, half-life filtering, and an information table.

This is an indicator, not a strategy. It does not place orders, does not execute trades, and does not produce TradingView Strategy Tester backtest results. All markers are visual statistical events only and should not be treated as guaranteed trading signals or financial advice.

2. Core Idea

The indicator measures how far the selected series is from its rolling average in standard deviation units.

A positive Z-score means the selected series is above its rolling mean.

A negative Z-score means the selected series is below its rolling mean.

The general mean-reversion idea is that extreme deviations may sometimes revert back toward the mean, but this is not guaranteed. Markets can remain extended, trend further, or fail to mean-revert.

3. Z-score Calculation

The script calculates:

* Rolling mean
* Rolling standard deviation
* Current Z-score

The Z-score is calculated from the selected series using the chosen lookback length.

The indicator plots:

* Z-score line
* Mean line at 0
* Entry bands
* Normal exit bands
* Extreme bands

4. Information Table

https://www.tradingview.com/x/ThUeC6M8/

The indicator includes an information table designed to summarize the current statistical state of the Z-score setup.

The table helps users understand the current condition without relying only on the plotted markers.

The table can show:

Z now

The current Z-score value.

This shows how far the selected series is from its rolling mean in standard deviation units.

Half-life

Shows the estimated mean-reversion half-life in bars.

If a valid half-life is not detected, the table can show that there is no current reversion condition.

Edge?

This row shows whether the half-life gate supports mean reversion.

FADE OK

This means the half-life filter currently supports a mean-reversion condition.

DO NOT FADE

This means the half-life filter does not currently support a mean-reversion condition.

This is important because the Z-score may be extreme, but the script may still block the setup if the statistical mean-reversion gate is not valid.

Position

Shows the script’s internal visual position state:

FLAT

No visual position state is active.

LONG ACTIVE

A long-side visual state is active.

SHORT ACTIVE

A short-side visual state is active.

This is only internal marker tracking. It is not a real broker position and not a TradingView strategy position.

Entry

Shows the selected entry behavior.

Possible table examples include:

safer

Conservative entry mode.

early

Aggressive entry mode.

safer + near

Conservative entry mode with near-zone rebound entries enabled.

early + near

Aggressive entry mode with near-zone rebound entries enabled.

Risk exit

Shows whether the early Z-failure exit is enabled.

Guide

Shows a compact explanation of marker colors.

Example:

gray normal / orange fail / gold blocked

Dir

Shows the selected signal direction mode.

Possible values include:

long only

Only low-Z long-side events are allowed.

long + short

Both low-Z long events and high-Z short events are allowed.

Beta / Pair

In pairs mode, this row shows the selected beta mode and the second symbol used as leg B.

Examples:

auto beta / MSFT

manual beta / MSFT

ratio mode / MSFT

In single mode, beta is not applicable.

Why the information table matters

The information table is designed to make the indicator easier to read.

A Z-score extreme alone is not always enough. The table adds context by showing whether the selected series currently passes the half-life mean-reversion gate.

For example:

If the Z-score is extreme and the table shows FADE OK, the script is showing that the statistical gate supports mean-reversion conditions.

If the Z-score is extreme and the table shows DO NOT FADE, the script is warning that the half-life filter does not support fading that move.

This is why gold blocked markers and the information table should be reviewed together.

5. Single and Pairs Modes

The indicator includes two calculation modes:

Single mode

Single mode calculates the Z-score directly from the selected source, such as close price.

This mode is useful when the user wants to study whether one symbol is statistically extended above or below its own rolling mean.

Pairs mode

Pairs mode compares the main chart symbol against a second symbol selected by the user.

The second symbol is used as leg B.

Pairs mode supports:

* Log-spread mode
* Ratio mode
* Manual beta
* Auto rolling beta

Log-spread mode

When log-spread is enabled, the script calculates a spread using:

log(A) - beta × log(B)

This is commonly used in pairs and relative-value analysis.

Ratio mode

When log-spread is disabled, the script uses a simple ratio between symbol A and symbol B.

Auto rolling beta

When enabled in log-spread pairs mode, the script estimates a rolling beta between log(A) and log(B) using the selected lookback window.

Manual beta

Manual beta allows the user to enter a fixed hedge ratio.

Important note about pairs mode

Pairs analysis is sensitive to symbol selection, timeframe, beta stability, liquidity, and market regime. A spread that looked mean-reverting historically may stop mean-reverting. Users should validate pairs relationships independently.

6. Statistical Bands

Mean

The zero line represents the rolling mean reference.

Entry bands

The positive and negative entry bands define the main statistical extension zone.

For example:

+2 Z may represent an upper statistical extension.

-2 Z may represent a lower statistical extension.

Extreme bands

The extreme bands mark deeper statistical extensions.

For example:

+3 Z or -3 Z may indicate a stronger deviation from the rolling mean.

Normal exit bands

The normal exit bands are closer to the mean and are used for visual normal-exit conditions when the Z-score reverts toward the mean.

7. Half-life Mean-Reversion Gate

The script includes a half-life filter designed to check whether the selected series currently shows mean-reversion behavior.

The half-life estimate attempts to measure how quickly deviations may revert toward the mean.

If the half-life condition supports mean reversion, the information table shows:

FADE OK

If the half-life condition does not support mean reversion, the information table shows:

DO NOT FADE

Important note about half-life

Half-life is an estimate based on recent data. It is not a prediction and does not guarantee that price will revert. It is used as a statistical filter to reduce mean-reversion attempts when the series does not currently show a valid mean-reversion profile.

8. Signal Direction

The script supports two direction modes:

Long only

Only low-Z long-side statistical events are allowed.

Both long + short

Low-Z long-side events and high-Z short-side events are allowed.

9. Entry Styles

The script includes two entry styles:

Conservative / Safer

The conservative style waits for the Z-score to first move into an extreme zone, then start reverting back from that zone.

This is designed to avoid entering while the Z-score is still moving deeper into the extreme area.

Aggressive / Early

The aggressive style marks an entry event as soon as the Z-score reaches the selected entry band.

This can create earlier entries, but it may also increase the risk of entering before the move has finished extending.

10. Near-Zone Rebound Entries

The script includes optional near-zone rebound entries.

This feature can mark a rebound when the Z-score nearly reaches the full entry band but does not fully touch it.

Example:

If the main entry band is 2.0 Z and the near-zone band is 1.7 Z, the script can detect a rebound from the 1.7 area.

This feature is intended to catch practical rebounds that occur before the full statistical band is reached.

11. Position-State Tracking

The script tracks a simple internal visual position state:

* Flat
* Long active
* Short active

This state is used only to organize markers and avoid overlapping entry/exit logic. It is not a real broker position and not a TradingView strategy position.

12. Entry Markers

The script can display entry markers on the Z-score pane.

Long Entry

A long entry marker appears when the selected long-side statistical entry condition is met.

Short Entry

A short entry marker appears when the selected short-side statistical entry condition is met and short direction is enabled.

These markers are statistical events only. They are not guaranteed buy or sell signals.

13. Exit Logic

https://www.tradingview.com/x/Yn15eQNP/

The script includes several visual exit event types.

Normal exit

A normal exit appears when the Z-score reverts back toward the selected normal exit band.

This represents a normal mean-reversion completion event.

Early Z-failure exit

An early failure exit appears when the Z-score fails and moves back beyond the entry band after an active visual position state exists.

This is designed to show a possible statistical failure condition.

Optional price candle failure exit

When enabled, the script can use the entry candle’s high or low as a simple price-failure reference.

For long visual states, price failure can occur if price closes below the entry candle low.

For short visual states, price failure can occur if price closes above the entry candle high.

This feature is OFF by default because it can be sensitive.

Optional emergency Z-stop

When enabled, the script can mark an emergency Z-stop if the Z-score extends further against the active visual position beyond the selected emergency Z-stop level.

This is OFF by default.

14. Marker Guide

The script uses stable markers that are placed away from the Z-score line to reduce overlap.

Long entry marker

A low-Z long-side entry event.

Short entry marker

A high-Z short-side entry event.

Gray X

Normal exit after Z-score reverts toward the mean.

Orange X

Early failure exit.

Red X

Emergency Z-stop exit.

Gold dot

Blocked setup marker.

15. Blocked Setup Markers

https://www.tradingview.com/x/vhYkri2H/

The gold dot appears when the Z-score reaches an extreme area, but the half-life filter does not support mean reversion.

This is not an entry marker.

It is a warning that the Z-score is extreme, but the statistical mean-reversion gate is blocking the setup.

16. Alerts

The script includes alert conditions for:

* Long entry
* Short entry
* Blocked low-Z setup
* Blocked high-Z setup
* Normal exit
* Early failure exit
* Emergency Z-stop
* Any exit

Alerts are notifications only. They do not place orders and do not confirm broker execution.

17. How to Use This Indicator

A practical workflow:

1. Choose Single mode or Pairs mode.

2. Select the source series or pair symbol.

3. Choose the lookback length for mean and standard deviation.

4. Select the entry band, normal exit band, and extreme band.

5. Review the information table.

6. Check whether the table shows FADE OK or DO NOT FADE.

7. Use conservative mode if you prefer confirmation after the Z-score starts reverting.

8. Use aggressive mode only if you understand the risk of earlier entries.

9. Review blocked setup markers to see when the half-life gate is rejecting extreme Z-score conditions.

10. Use normal exit, failure exit, and emergency exit markers to study how the Z-score reverts or fails.

11. Combine the indicator with broader market context, liquidity, trend, risk management, and independent analysis.

12. Suggested Use Cases

Z-Score Statistical Bands can be used for:

* Mean-reversion study
* Statistical deviation analysis
* Pairs spread monitoring
* Relative-value analysis
* Z-score band observation
* Half-life filtering
* Reversion timing study
* Exit event visualization
* Blocked setup review
* Statistical context review through the information table

19. Important Limitations

This indicator does not predict future price movement.

It does not guarantee mean reversion.

It does not guarantee profitable trades.

It is not a trading strategy.

It does not place orders.

It does not produce Strategy Tester results.

Z-score extremes can become more extreme.

Mean-reversion conditions can fail.

Half-life is an estimate, not a certainty.

Pairs relationships can change over time.

Rolling beta can be unstable in changing market regimes.

Ratio and log-spread methods can produce different results.

Pairs mode requires valid data for the selected second symbol.

Log calculations require positive price values.

Signal markers are statistical events, not trading instructions.

Exit markers are visual events, not broker fills.

The internal position state shown in the table is only a visual tracking state, not a real trading position.

Users are responsible for their own trading decisions, risk management, and position sizing.

20. Originality and Purpose

Z-Score Statistical Bands combines several statistical mean-reversion tools into one organized indicator:

* Single-symbol Z-score analysis
* Pairs spread Z-score analysis
* Log-spread and ratio modes
* Manual and rolling beta options
* Half-life mean-reversion gate
* Conservative and aggressive entry styles
* Near-zone rebound entries
* Internal visual position-state tracking
* Normal exit markers
* Early failure exit markers
* Optional price failure exit
* Optional emergency Z-stop
* Blocked setup markers
* Information table
* Alert conditions

The purpose of the script is to help traders study statistical extension, mean-reversion conditions, and pairs-spread behavior in a structured and visual way.

21. Educational Disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users should perform their own analysis and manage risk independently.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// Z-Score Statistical Bands
// ============================================================================
// Mean-reversion Z-score indicator with:
// - Single and Pairs modes.
// - Conservative / Aggressive entry styles.
// - Optional Near-Zone Rebound entries.
// - Half-life mean-reversion gate.
// - Position-state tracking.
// - Cleaner early failure exit.
// - Optional price failure exit.
// - Optional emergency Z-stop.
// - Stable markers.
// - Exit markers do not overlap the Z-score line.
// - Blocked setup markers show when Z is extreme but Half-life blocks entry.
// - Clear Style-tab names.
// ============================================================================

indicator("Z-Score Statistical Bands", "Z-Score Bands", overlay=false, precision=2)

// ---------------------------------------------------------------------------
// Inputs
// ---------------------------------------------------------------------------
mode = input.string("Single (mean reversion)", "Mode", options=["Single (mean reversion)", "Pairs (spread vs symbol B)"], group="Series")
src = input.source(close, "Source (leg A)", group="Series")
symB = input.symbol("NASDAQ:MSFT", "Pair symbol B", group="Series", tooltip="Used only in Pairs mode.")
useLog = input.bool(true, "Pairs: log-spread (else ratio)", group="Series", tooltip="ON = log(A) - beta*log(B). OFF = simple ratio A/B.")
betaMode = input.string("Auto rolling beta", "Pairs beta mode", options=["Auto rolling beta", "Manual beta"], group="Series", tooltip="Auto beta is used only in log-spread pairs mode.")
betaManual = input.float(1.0, "Manual hedge ratio beta", minval=0.0, step=0.1, group="Series")
betaLen = input.int(100, "Auto beta lookback", minval=20, group="Series", tooltip="Rolling regression window used to estimate beta between log(A) and log(B).")

dirMode = input.string("Long only", "Signal direction", options=["Long only", "Both (long + short)"], group="Signals", tooltip="Long only means low-Z long entries only. Both enables high-Z short entries as well.")
entryStyle = input.string("Conservative / Safer", "Entry style", options=["Conservative / Safer", "Aggressive / Early"], group="Signals", tooltip="Conservative waits for Z to start reverting back from the extreme zone. Aggressive enters as soon as Z reaches the extreme zone.")
useNearEntry = input.bool(true, "Use near-zone rebound entries", group="Signals", tooltip="Adds a practical rebound entry when Z nearly reaches the entry band but does not fully touch it. Helps catch deep pullbacks that rebound before -2/+2.")
nearZ = input.float(1.7, "Near setup band (Z)", minval=1.0, step=0.1, group="Signals", tooltip="Near-zone threshold. Example: 1.7 catches rebounds that do not fully reach the standard 2.0 entry band.")
length = input.int(100, "Lookback (mean / stdev)", minval=5, group="Signals")
entryZ = input.float(2.0, "Entry band (Z)", minval=0.5, step=0.1, group="Signals")
exitZ = input.float(0.5, "Normal exit band (Z)", minval=0.0, step=0.1, group="Signals")
extZ = input.float(3.0, "Extreme band (Z)", minval=1.0, step=0.1, group="Signals")

useEarlyExit = input.bool(true, "Use early Z-failure exit", group="Risk", tooltip="Early exit when Z fails back beyond the entry band after a trade is active.")
usePriceFail = input.bool(false, "Use price candle failure exit", group="Risk", tooltip="Optional. Long exits if price closes below the entry candle low. Short exits if price closes above the entry candle high. OFF by default because it can be too sensitive.")
useStop = input.bool(false, "Use emergency Z-stop exit", group="Risk", tooltip="Emergency exit when Z extends further against the position. Off by default.")
stopZ = input.float(4.0, "Emergency Z-stop level (abs)", minval=2.5, step=0.1, group="Risk", tooltip="Long exits if Z crosses below -this level. Short exits if Z crosses above +this level.")

showSig = input.bool(true, "Show entry marks", group="Display")
showNormalExit = input.bool(true, "Show normal exit marks", group="Display")
showEarlyExit = input.bool(true, "Show early exit marks", group="Display")
showBlocked = input.bool(true, "Show blocked setup marks", group="Display", tooltip="Shows a small gold dot when Z reaches an extreme but Half-life blocks the trade.")
showHL = input.bool(true, "Show half-life in table", group="Display")
showBeta = input.bool(true, "Show beta in table", group="Display")
showGuide = input.bool(true, "Show guide in table", group="Display")
tableSizeOpt = input.string("Normal", "Table text size", options=["Small", "Normal", "Large", "Huge"], group="Display")
markerOffset = input.float(0.40, "Signal marker offset", minval=0.1, step=0.1, group="Display")
posStr = input.string("top_right", "Table position", options=["top_left", "top_right", "bottom_left", "bottom_right", "middle_left", "middle_right"], group="Display")

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
f_pos(s) =>
    s == "top_left" ? position.top_left : s == "top_right" ? position.top_right : s == "bottom_left" ? position.bottom_left : s == "bottom_right" ? position.bottom_right : s == "middle_left" ? position.middle_left : position.middle_right

f_size(s) =>
    s == "Small" ? size.small : s == "Normal" ? size.normal : s == "Large" ? size.large : size.huge

tblSize = f_size(tableSizeOpt)

// ---------------------------------------------------------------------------
// Palette
// ---------------------------------------------------------------------------
cHi = color.rgb(205, 85, 95)
cLo = color.rgb(54, 168, 112)
cMid = color.rgb(150, 158, 170)
cWarn = color.rgb(235, 142, 52)
cBlock = color.rgb(210, 170, 65)
cCard = color.rgb(16, 20, 26)
cHdr = color.new(color.white, 10)
cDim = color.new(color.white, 40)

// ---------------------------------------------------------------------------
// Series Y
// ---------------------------------------------------------------------------
isPairs = mode == "Pairs (spread vs symbol B)"
bClose = request.security(symB, timeframe.period, close, ignore_invalid_symbol=true)

validA = not na(src) and src > 0
validB = not na(bClose) and bClose > 0

logA = validA ? math.log(src) : na
logB = validB ? math.log(bClose) : na

meanA_beta = ta.sma(logA, betaLen)
meanB_beta = ta.sma(logB, betaLen)
covAB = ta.sma(logA * logB, betaLen) - meanA_beta * meanB_beta
varB = ta.sma(logB * logB, betaLen) - meanB_beta * meanB_beta
betaAuto = varB != 0 ? covAB / varB : na

useAutoBeta = isPairs and useLog and betaMode == "Auto rolling beta"
betaUsed = useAutoBeta and not na(betaAuto) ? betaAuto : betaManual

ySingle = src
yPairsLog = validA and validB ? logA - betaUsed * logB : na
yPairsRatio = validB and bClose != 0 ? src / bClose : na
y = isPairs ? (useLog ? yPairsLog : yPairsRatio) : ySingle

// ---------------------------------------------------------------------------
// Z-score
// ---------------------------------------------------------------------------
mean = ta.sma(y, length)
sd = ta.stdev(y, length)
z = sd != 0 ? (y - mean) / sd : na

// ---------------------------------------------------------------------------
// Half-life
// ---------------------------------------------------------------------------
ylag = y[1]
dy = y - ylag

mlag = ta.sma(ylag, length)
mdy = ta.sma(dy, length)

covv = ta.sma(ylag * dy, length) - mlag * mdy
varr = ta.sma(ylag * ylag, length) - mlag * mlag

bcoef = varr != 0 ? covv / varr : na
halflife = not na(bcoef) and bcoef < 0 ? -math.log(2) / bcoef : na
meanReverting = not na(halflife) and halflife > 0 and halflife < length

allowShort = dirMode == "Both (long + short)"
isConservative = entryStyle == "Conservative / Safer"

// ---------------------------------------------------------------------------
// Plot Z + bands
// ---------------------------------------------------------------------------
zcol = na(z) ? cMid : z > 0 ? color.from_gradient(z, 0, extZ, cMid, cHi) : color.from_gradient(z, -extZ, 0, cLo, cMid)
plot(z, "Z-score", color=zcol, linewidth=2)

hUpExt = hline(extZ, "Extreme +", color=color.new(cHi, 40), linestyle=hline.style_dotted)
hUp = hline(entryZ, "Entry +", color=color.new(cHi, 30))
hUpX = hline(exitZ, "Normal Exit +", color=color.new(cMid, 55), linestyle=hline.style_dashed)
hMid = hline(0.0, "Mean", color=color.new(color.gray, 30))
hDnX = hline(-exitZ, "Normal Exit -", color=color.new(cMid, 55), linestyle=hline.style_dashed)
hDn = hline(-entryZ, "Entry -", color=color.new(cLo, 30))
hDnExt = hline(-extZ, "Extreme -", color=color.new(cLo, 40), linestyle=hline.style_dotted)

fill(hUp, hUpExt, color=color.new(cHi, 88))
fill(hDn, hDnExt, color=color.new(cLo, 88))

// ---------------------------------------------------------------------------
// Signal engine with position-state tracking
// ---------------------------------------------------------------------------
var int pos = 0
var bool longArmed = false
var bool shortArmed = false
var bool longNearArmed = false
var bool shortNearArmed = false
var float entryRiskLow = na
var float entryRiskHigh = na

// Aggressive entries
longEntryAggressive = meanReverting and ta.crossunder(z, -entryZ)
shortEntryAggressive = allowShort and meanReverting and ta.crossover(z, entryZ)

// Conservative arming
if pos == 0 and meanReverting and z < -entryZ
    longArmed := true

if pos == 0 and allowShort and meanReverting and z > entryZ
    shortArmed := true

// Near-zone arming
if useNearEntry and pos == 0 and meanReverting and z < -nearZ
    longNearArmed := true

if useNearEntry and pos == 0 and allowShort and meanReverting and z > nearZ
    shortNearArmed := true

// Conservative confirmation
longEntryConservative = pos == 0 and longArmed and meanReverting and ta.crossover(z, -entryZ)
shortEntryConservative = pos == 0 and shortArmed and meanReverting and ta.crossunder(z, entryZ)

// Near-zone confirmation
longEntryNear = useNearEntry and pos == 0 and longNearArmed and meanReverting and ta.crossover(z, -nearZ)
shortEntryNear = useNearEntry and pos == 0 and shortNearArmed and meanReverting and ta.crossunder(z, nearZ)

// Reset stale arms
if pos == 0 and z > 0
    longArmed := false
    longNearArmed := false

if pos == 0 and z < 0
    shortArmed := false
    shortNearArmed := false

rawLongEntry = (isConservative ? longEntryConservative : longEntryAggressive) or longEntryNear
rawShortEntry = (isConservative ? shortEntryConservative : shortEntryAggressive) or shortEntryNear

longEntry = pos == 0 and rawLongEntry
shortEntry = pos == 0 and rawShortEntry

// Normal exits: reversion toward mean
longNormalExit = pos == 1 and ta.crossover(z, -exitZ)
shortNormalExit = pos == -1 and ta.crossunder(z, exitZ)

// Early Z-failure exits
longZFail = useEarlyExit and pos == 1 and ta.crossunder(z, -entryZ)
shortZFail = useEarlyExit and pos == -1 and ta.crossover(z, entryZ)

// Optional price candle failure exits
longPriceFail = usePriceFail and pos == 1 and not na(entryRiskLow) and close < entryRiskLow
shortPriceFail = usePriceFail and pos == -1 and not na(entryRiskHigh) and close > entryRiskHigh

longFailureExit = longZFail or longPriceFail
shortFailureExit = shortZFail or shortPriceFail

// Emergency Z-stop
longEmergencyStop = useStop and pos == 1 and ta.crossunder(z, -stopZ)
shortEmergencyStop = useStop and pos == -1 and ta.crossover(z, stopZ)

longExit = longNormalExit or longFailureExit or longEmergencyStop
shortExit = shortNormalExit or shortFailureExit or shortEmergencyStop

failureExitSignal = longFailureExit or shortFailureExit
emergencyExitSignal = longEmergencyStop or shortEmergencyStop
normalExitSignal = (longNormalExit or shortNormalExit) and not failureExitSignal and not emergencyExitSignal
exitSignal = longExit or shortExit

if longEntry
    pos := 1
    entryRiskLow := low
    entryRiskHigh := high
    longArmed := false
    shortArmed := false
    longNearArmed := false
    shortNearArmed := false
else if shortEntry
    pos := -1
    entryRiskLow := low
    entryRiskHigh := high
    longArmed := false
    shortArmed := false
    longNearArmed := false
    shortNearArmed := false
else if exitSignal
    pos := 0
    entryRiskLow := na
    entryRiskHigh := na
    longArmed := false
    shortArmed := false
    longNearArmed := false
    shortNearArmed := false

// ---------------------------------------------------------------------------
// Blocked setup logic
// ---------------------------------------------------------------------------
// Gold dot = Z reached an extreme, but the Half-life gate blocked the trade.
// This is not an entry. It is a "do not fade" warning.
blockedLong = showBlocked and pos == 0 and not meanReverting and ta.crossunder(z, -entryZ)
blockedShort = showBlocked and allowShort and pos == 0 and not meanReverting and ta.crossover(z, entryZ)

// ---------------------------------------------------------------------------
// Stable signal markers - exit markers do not overlap the Z-score line
// ---------------------------------------------------------------------------
longEntryY = showSig and longEntry ? -extZ - markerOffset : na
shortEntryY = showSig and shortEntry ? extZ + markerOffset : na

longNormalExitY = showNormalExit and longNormalExit ? -extZ + markerOffset : na
shortNormalExitY = showNormalExit and shortNormalExit ? extZ - markerOffset : na

longFailureExitY = showEarlyExit and longFailureExit ? -extZ + markerOffset : na
shortFailureExitY = showEarlyExit and shortFailureExit ? extZ - markerOffset : na

longEmergencyExitY = showEarlyExit and longEmergencyStop ? -extZ + markerOffset : na
shortEmergencyExitY = showEarlyExit and shortEmergencyStop ? extZ - markerOffset : na

blockedLongY = blockedLong ? -extZ : na
blockedShortY = blockedShort ? extZ : na

plotshape(longEntryY, "Long Entry", style=shape.triangleup, location=location.absolute, color=cLo, size=size.tiny)
plotshape(shortEntryY, "Short Entry", style=shape.triangledown, location=location.absolute, color=cHi, size=size.tiny)

plotshape(blockedLongY, "Gold Dot - Blocked Low-Z Setup (No Fade)", style=shape.circle, location=location.absolute, color=cBlock, size=size.tiny)
plotshape(blockedShortY, "Gold Dot - Blocked High-Z Setup (No Fade)", style=shape.circle, location=location.absolute, color=cBlock, size=size.tiny)

plotshape(longNormalExitY, "Gray X - Long Normal Exit", style=shape.xcross, location=location.absolute, color=color.new(cMid, 0), size=size.tiny)
plotshape(shortNormalExitY, "Gray X - Short Normal Exit", style=shape.xcross, location=location.absolute, color=color.new(cMid, 0), size=size.tiny)

plotshape(longFailureExitY, "Orange X - Long Early Failure Exit", style=shape.xcross, location=location.absolute, color=cWarn, size=size.tiny)
plotshape(shortFailureExitY, "Orange X - Short Early Failure Exit", style=shape.xcross, location=location.absolute, color=cWarn, size=size.tiny)

plotshape(longEmergencyExitY, "Red X - Long Emergency Z-Stop", style=shape.xcross, location=location.absolute, color=cHi, size=size.tiny)
plotshape(shortEmergencyExitY, "Red X - Short Emergency Z-Stop", style=shape.xcross, location=location.absolute, color=cHi, size=size.tiny)

// ---------------------------------------------------------------------------
// Badge / Table
// ---------------------------------------------------------------------------
biasTxt = na(z) ? "--" : z <= -entryZ ? "LONG SETUP" : z >= entryZ and allowShort ? "SHORT SETUP" : z >= entryZ and not allowShort ? "RICH / NO SHORT" : "NEUTRAL"
biasCol = na(z) ? cMid : z <= -entryZ ? cLo : z >= entryZ ? cHi : cMid

edgeTxt = meanReverting ? "FADE OK" : "DO NOT FADE"
edgeCol = meanReverting ? cLo : cHi

hlTxt = not showHL ? "hidden" : na(halflife) ? "no reversion" : str.tostring(halflife, "#.#") + " bars"

betaTxt = not isPairs ? "n/a" : not useLog ? "ratio mode" : not showBeta ? "hidden" : (useAutoBeta ? "auto " : "manual ") + str.tostring(betaUsed, "#.###")

dirTxt = isPairs and not allowShort ? "low-Z only" : allowShort ? "long + short" : "long only"

entryTxt = isConservative ? (useNearEntry ? "safer + near" : "safer") : (useNearEntry ? "early + near" : "early")
riskTxt = useEarlyExit ? "Z fail ON" : "Z fail OFF"
guideTxt = showGuide ? "gray normal / orange fail / gold blocked" : "hidden"

pairTxt = isPairs ? str.replace_all(str.replace_all(str.replace_all(symB, "NASDAQ:", ""), "NYSE:", ""), "AMEX:", "") : "n/a"

posTxt = pos == 1 ? "LONG ACTIVE" : pos == -1 ? "SHORT ACTIVE" : "FLAT"
posCol = pos == 1 ? cLo : pos == -1 ? cHi : cMid

var table tbl = table.new(f_pos(posStr), 2, 10, bgcolor=cCard, frame_color=color.new(color.gray, 55), frame_width=1, border_color=color.new(color.gray, 70), border_width=1)

if barstate.islast
    table.cell(tbl, 0, 0, isPairs ? "Z-SCORE PAIRS" : "Z-SCORE", text_color=biasCol, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 0, biasTxt, text_color=cCard, bgcolor=biasCol, text_size=tblSize)

    table.cell(tbl, 0, 1, "Z now", text_color=cHdr, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 1, na(z) ? "--" : str.tostring(z, "#.##"), text_color=cHdr, bgcolor=cCard, text_size=tblSize)

    table.cell(tbl, 0, 2, "Half-life", text_color=cHdr, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 2, hlTxt, text_color=meanReverting ? cLo : cHi, bgcolor=cCard, text_size=tblSize)

    table.cell(tbl, 0, 3, "Edge?", text_color=cDim, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 3, edgeTxt, text_color=edgeCol, bgcolor=cCard, text_size=tblSize)

    table.cell(tbl, 0, 4, "Position", text_color=cDim, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 4, posTxt, text_color=posCol, bgcolor=cCard, text_size=tblSize)

    table.cell(tbl, 0, 5, "Entry", text_color=cDim, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 5, entryTxt, text_color=isConservative ? cLo : cHi, bgcolor=cCard, text_size=tblSize)

    table.cell(tbl, 0, 6, "Risk exit", text_color=cDim, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 6, riskTxt, text_color=useEarlyExit ? cWarn : cDim, bgcolor=cCard, text_size=tblSize)

    table.cell(tbl, 0, 7, "Guide", text_color=cDim, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 7, guideTxt, text_color=cDim, bgcolor=cCard, text_size=tblSize)

    table.cell(tbl, 0, 8, "Dir", text_color=cDim, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 8, dirTxt, text_color=cDim, bgcolor=cCard, text_size=tblSize)

    table.cell(tbl, 0, 9, isPairs ? "Beta / Pair" : "Beta", text_color=cDim, bgcolor=cCard, text_size=tblSize, text_halign=text.align_left)
    table.cell(tbl, 1, 9, isPairs ? betaTxt + " / " + pairTxt : "n/a", text_color=cDim, bgcolor=cCard, text_size=tblSize)

// ---------------------------------------------------------------------------
// Alerts
// ---------------------------------------------------------------------------
alertcondition(longEntry, "Long entry (Z low)", "Z-Score Statistical Bands: long entry based on selected entry style and near-zone setting")
alertcondition(shortEntry, "Short entry (Z high)", "Z-Score Statistical Bands: short entry based on selected entry style and near-zone setting")
alertcondition(blockedLong, "Blocked low-Z setup", "Z-Score Statistical Bands: low-Z extreme blocked because Half-life does not support mean reversion")
alertcondition(blockedShort, "Blocked high-Z setup", "Z-Score Statistical Bands: high-Z extreme blocked because Half-life does not support mean reversion")
alertcondition(normalExitSignal, "Normal exit", "Z-Score Statistical Bands: normal exit - reverted toward mean")
alertcondition(failureExitSignal, "Early failure exit", "Z-Score Statistical Bands: early failure exit - Z failed back beyond entry band")
alertcondition(emergencyExitSignal, "Emergency Z-stop", "Z-Score Statistical Bands: emergency Z-stop exit")
alertcondition(exitSignal, "Any exit", "Z-Score Statistical Bands: exit signal")

// ============================================================================
// End of file
// ============================================================================
````
