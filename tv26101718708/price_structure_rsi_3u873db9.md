# Price Structure RSI

- url: https://www.tradingview.com/script/3U873dB9-Price-Structure-RSI/
- type: indicator
- pine_id: PUB;eeb9ccef732d4b94be32e0457c7791c8
- version: 1.0

## Description

Overview

Price Structure RSI is a market-structure oscillator that converts confirmed structural breaks into a cumulative directional series and then applies the Relative Strength Index calculation to that series.

Unlike a traditional RSI, which is calculated directly from price changes, this indicator measures how previously identified pivot highs and pivot lows are being broken.

The oscillator includes:

- market-structure-based RSI
- configurable RSI length
- configurable overbought and oversold levels
- Close or High/Low structure-break confirmation
- optional EMA, SMA, or WMA smoothing
- confirmed bullish and bearish signals
- dark and light colour presets
- gradient oscillator visualization
- simplified bullish and bearish historical W/L panels
- configurable target and stop distances
- configurable panel positions
- bullish and bearish alerts

The indicator is intended to help users examine whether recent market-structure breaks are producing stronger bullish or bearish pressure.

It does not predict future price movement and does not provide automatic instructions to enter or exit a trade.


Open-source reuse and credits

Price Structure RSI is a modified and expanded derivative of the open-source indicator "Market Structure RSI" by ClayeWeight.

The original pivot detection, stored structure levels, broken-structure accumulation, cumulative structure total, RSI transformation, moving-average selection, threshold-crossing signals, and alert framework were adapted from ClayeWeight's work.

This version adds:

- Pine Script v6 compatibility
- dark and light colour presets
- revised oscillator colours and gradient fills
- confirmed-bar signal processing
- configurable historical target and stop measurements
- next-bar outcome evaluation
- conservative same-bar target and stop handling
- separate bullish and bearish W/L panels
- configurable panel positioning and offsets
- additional input validation
- revised alert messages

The original source was published under the Mozilla Public License 2.0.

This modified version is also published open-source under the Mozilla Public License 2.0.


Core methodology

The indicator first identifies simple confirmed pivot highs and pivot lows.

A pivot high is identified when:

- the centre candle has a higher high than the candle before it
- the centre candle has a higher high than the candle after it

A pivot low is identified when:

- the centre candle has a lower low than the candle before it
- the centre candle has a lower low than the candle after it

Because the script evaluates historical candles, the pivot is recognized only after the necessary later candle has closed.

Confirmed pivot-high prices are stored in an array.

Confirmed pivot-low prices are stored in a separate array.


Structure breaks

The indicator checks whether stored pivot levels have been broken.

Users can select one of two Structure Break Type settings:

- Close
- High/Low

When Close is selected:

- a stored pivot high is considered broken when the previous candle closes above it
- a stored pivot low is considered broken when the previous candle closes below it

When High/Low is selected:

- a stored pivot high is considered broken when the previous candle high moves above it
- a stored pivot low is considered broken when the previous candle low moves below it

When one or more stored pivot highs are broken, positive values are added to the cumulative structure total.

When one or more stored pivot lows are broken, negative values are added to the cumulative structure total.

Broken levels are removed from their respective arrays so that the same structure level is not counted repeatedly.


Cumulative structure total

Each broken pivot high contributes:

- +1

Each broken pivot low contributes:

- -1

If several stored structure levels are broken together, several values can be added during the same calculation.

The script then calculates the cumulative sum of these positive and negative structure changes.

A rising structure total indicates that more stored pivot highs are being broken.

A falling structure total indicates that more stored pivot lows are being broken.


Structure RSI

The Relative Strength Index calculation is applied to the cumulative structure total rather than directly to price.

The default RSI Length is:

- 20

The resulting oscillator is called the Structure RSI.

Higher Structure RSI values indicate that bullish structure breaks have recently had greater influence on the cumulative series.

Lower Structure RSI values indicate that bearish structure breaks have recently had greater influence.

The Structure RSI should not be interpreted as a standard price RSI because its input is the cumulative structure-break series rather than normal closing-price changes.


Overbought and oversold levels

The default levels are:

- Overbought Level: 80
- Oversold Level: 20

The Oversold Level must remain below the Overbought Level.

The script displays an error when the oversold setting is equal to or above the overbought setting.

The levels are configurable and should be treated as analytical thresholds rather than universally optimal settings.


Bullish signal

A bullish signal occurs when the Structure RSI crosses upward through the selected Oversold Level.

The signal is confirmed only after the chart candle closes.

The bullish marker appears at the bottom of the oscillator pane.

A bullish signal indicates that the structure-based oscillator has recovered above its lower threshold.

It does not guarantee that price will continue higher.


Bearish signal

A bearish signal occurs when the Structure RSI crosses downward through the selected Overbought Level.

The signal is confirmed only after the chart candle closes.

The bearish marker appears at the top of the oscillator pane.

A bearish signal indicates that the structure-based oscillator has moved back below its upper threshold.

It does not guarantee that price will continue lower.


Moving average

An optional moving average can be applied to the Structure RSI.

Available moving-average types are:

- EMA
- SMA
- WMA

The default settings are:

- Moving Average Type: EMA
- Moving Average Length: 8

The moving average can be used to observe the smoother direction of the Structure RSI.

The moving average does not directly create the bullish or bearish threshold signals.

Hiding the moving average does not change the Structure RSI calculation.


Oscillator colours

The Structure RSI line changes colour according to its current position.

- Above the Overbought Level: bearish colour
- Below the Oversold Level: bullish colour
- Between the two levels: neutral grey

The oscillator also includes:

- a dashed overbought line
- a dashed oversold line
- a dotted 50 midline
- a neutral background fill between the main levels
- bullish and bearish gradient fills
- optional dark and light colour presets

The colour settings change presentation only.

They do not alter the structure calculation or signal logic.


Confirmed signals

Bullish and bearish signals are accepted only on confirmed chart bars.

The script does not finalize a signal solely because the Structure RSI temporarily crosses a threshold while the active candle is still open.

Values may still move while the current chart candle develops.

The final marker and alert are generated only after the candle closes with the crossing condition confirmed.


Historical W/L measurements

The indicator includes simplified historical bullish and bearish outcome measurements.

These measurements are not a complete TradingView strategy backtest.

When no measurement is currently active, a confirmed signal can begin a new historical measurement.

For a bullish signal:

- the signal candle close becomes the recorded entry price
- the target is placed above the recorded entry
- the stop is placed below the recorded entry

For a bearish signal:

- the signal candle close becomes the recorded entry price
- the target is placed below the recorded entry
- the stop is placed above the recorded entry

Only one unresolved historical measurement is tracked at a time.


Target distance

Target Distance (%) controls the percentage distance between the recorded signal close and the historical target.

The default value is:

- 1.0%

For a bullish measurement:

- Target = Entry Price × (1 + Target Percentage)

For a bearish measurement:

- Target = Entry Price × (1 - Target Percentage)

The minimum allowed target distance is 0.1%.


Stop distance

Stop Distance (%) controls the percentage distance between the recorded signal close and the historical stop.

The default value is:

- 1.0%

For a bullish measurement:

- Stop = Entry Price × (1 - Stop Percentage)

For a bearish measurement:

- Stop = Entry Price × (1 + Stop Percentage)

The minimum allowed stop distance is 0.1%.


Next-bar evaluation

Target and stop evaluation begins on the bar after the signal.

The signal candle itself is not used to determine the result.

This prevents price movement that occurred earlier during the signal candle from being counted after the entry has been recorded at that candle's close.


Wins and losses

The tables use the following labels:

- W = Win
- L = Loss

A win means that the configured target was reached before the configured stop.

A loss means that the configured stop was reached before the configured target.

The displayed percentage is:

- Wins divided by completed Wins and Losses

Bullish and bearish measurements are counted separately.


Same-bar target and stop handling

A chart candle can sometimes touch both the target and stop.

Standard OHLC chart data does not reveal which level was reached first inside that candle.

When both levels are touched during the same bar, the script records a loss.

This conservative rule avoids automatically assuming the more favourable outcome.

The script does not reconstruct lower-timeframe intrabar movement.


One active measurement at a time

Only one unresolved historical measurement can be active.

When a measurement is already active:

- later bullish or bearish signals can still appear
- later signals can still trigger alerts
- later signals do not start another W/L measurement
- the active measurement remains open until its target or stop is reached

An opposite signal does not automatically close the existing measurement.

This means that not every displayed signal is included in the W/L panels.


Bull panel

The Bull panel displays results from completed bullish measurements.

The panel contains:

- Bull
- W: number of bullish targets reached first
- L: number of bullish stops reached first
- percentage of completed bullish measurements recorded as wins

The Bull panel position can be selected from the available chart locations.


Bear panel

The Bear panel displays results from completed bearish measurements.

The panel contains:

- Bear
- W: number of bearish targets reached first
- L: number of bearish stops reached first
- percentage of completed bearish measurements recorded as wins

The Bear panel position can be selected independently from the Bull panel.


Panel positions and offsets

The Bull and Bear panels can be placed at:

- top left
- top centre
- top right
- middle left
- middle centre
- middle right
- bottom left
- bottom centre
- bottom right

Row and column offsets can be used to move each panel within the available position grid.

Negative row values move the selected panel upward.

Positive row values move it downward.

Negative column values move it to the left.

Positive column values move it to the right.

The final position is restricted to the available TradingView table locations.

The panels can overlap when both are assigned to the same effective position.


Meaning of the displayed percentage

The percentage represents the share of completed measurements where the configured target was reached before the configured stop.

It is not:

- a guaranteed win rate
- proof of future profitability
- a complete strategy result
- a recommendation to enter a trade
- a forecast of future performance

The historical measurement does not include:

- commissions
- spread
- slippage
- liquidity
- order execution
- position sizing
- account equity
- partial exits
- trailing stops
- market gaps
- order rejection
- overlapping positions
- complete intrabar sequencing

Historical results do not guarantee future results.


Alerts

The indicator includes two alert conditions:

- Bullish Signal
- Bearish Signal

The Bullish Signal alert is triggered when the Structure RSI crosses upward through the Oversold Level on a confirmed chart bar.

The Bearish Signal alert is triggered when the Structure RSI crosses downward through the Overbought Level on a confirmed chart bar.

When creating TradingView alerts, use:

- Once Per Bar Close

This matches the confirmed signal logic.


How to Use


1. Apply the indicator

Add Price Structure RSI to a standard TradingView chart.

The oscillator appears in a separate pane below the main price chart.


2. Begin with the default settings

The default configuration is:

- RSI Length: 20
- Overbought Level: 80
- Oversold Level: 20
- Structure Break Type: High/Low
- Moving Average Type: EMA
- Moving Average Length: 8
- Target Distance: 1.0%
- Stop Distance: 1.0%

Review the indicator with its default configuration before changing several settings simultaneously.


3. Select the structure-break type

Choose High/Low when a stored structure level should be considered broken as soon as the previous candle's high or low passes it.

Choose Close when the previous candle must close beyond the stored structure level.

High/Low is generally more responsive.

Close is generally more restrictive.

Neither setting is automatically more accurate.


4. Read the Structure RSI

Use the oscillator to observe the balance of recent broken pivot highs and pivot lows.

A rising oscillator indicates that bullish structure breaks are having greater recent influence.

A falling oscillator indicates that bearish structure breaks are having greater recent influence.

The oscillator can remain elevated or depressed during extended directional conditions.


5. Read the overbought area

When the Structure RSI moves above the Overbought Level, bullish structure-break pressure has pushed the oscillator into its upper region.

The bearish signal does not occur merely because the oscillator is above the level.

The bearish signal occurs only when the oscillator later crosses downward through the Overbought Level on a confirmed bar.


6. Read the oversold area

When the Structure RSI moves below the Oversold Level, bearish structure-break pressure has pushed the oscillator into its lower region.

The bullish signal does not occur merely because the oscillator is below the level.

The bullish signal occurs only when the oscillator later crosses upward through the Oversold Level on a confirmed bar.


7. Wait for the candle to close

Signals are confirmed at bar close.

Do not treat a temporary intrabar threshold crossing as a finalized signal.

Wait for the marker to remain after the chart candle closes.


8. Use the moving average

Enable the moving average to observe a smoother version of the Structure RSI.

Available types are:

- EMA
- SMA
- WMA

A shorter moving-average length reacts more quickly.

A longer moving-average length responds more slowly.

The moving average can provide visual context, but it is not part of the threshold-crossing signal condition.


9. Configure the target and stop distances

Set Target Distance (%) and Stop Distance (%) according to the historical measurement you want to study.

For example:

- Target: 1.0%
- Stop: 1.0%

This creates an equal-distance historical measurement.

Another example:

- Target: 2.0%
- Stop: 1.0%

This creates a larger target than stop.

These settings are research parameters and are not recommended trading settings.


10. Read the Bull panel

The Bull panel measures completed bullish signals.

- W means the bullish target was reached first
- L means the bullish stop was reached first
- the percentage shows bullish wins divided by completed bullish outcomes

Only signals that begin while no other measurement is active are included.


11. Read the Bear panel

The Bear panel measures completed bearish signals.

- W means the bearish target was reached first
- L means the bearish stop was reached first
- the percentage shows bearish wins divided by completed bearish outcomes

Only signals that begin while no other measurement is active are included.


12. Understand same-bar outcomes

When both the target and stop are touched during the same candle, the result is counted as a loss.

This is a conservative assumption because the chart's OHLC data cannot show which level was reached first.


13. Understand skipped measurements

A signal can appear while another historical measurement is still unresolved.

That signal can still:

- display a marker
- trigger an alert

However, it does not begin another historical measurement.

This is why the total W/L count may be lower than the total number of visible signals.


14. Position the panels

Choose separate positions for the Bull and Bear panels.

The default positions are:

- Bull panel: top left
- Bear panel: top right

Use the row and column offsets when small position adjustments are needed.

Avoid assigning both panels to the same final position unless overlapping panels are intended.


15. Select the colour preset

Use Dark Background on dark chart themes.

Use Light Background on light chart themes.

The preset changes moving-average and panel text colours.

It does not change the indicator calculations.


16. Create alerts

Create separate TradingView alerts for:

- Bullish Signal
- Bearish Signal

Use Once Per Bar Close.

Test alerts on the intended symbol and timeframe before using them operationally.


17. Review broader market context

Use Price Structure RSI together with additional analysis such as:

- trend direction
- price structure
- support and resistance
- volume
- volatility
- liquidity
- market sessions
- recent swing highs and lows
- scheduled economic or company events
- risk management

A threshold crossing alone does not guarantee a reversal or continuation.


Suggested starting process

- Apply the indicator to a standard candlestick chart
- Keep RSI Length at 20
- Keep the levels at 80 and 20
- Begin with High/Low structure breaks
- Keep the EMA smoothing line enabled
- Use a target and stop distance of 1.0%
- Wait for confirmed bar-close signals
- Compare the oscillator with visible price structure
- Review the Bull and Bear panels separately
- Remember that only one active measurement is tracked
- Test several symbols and timeframes before drawing conclusions
- Use Once Per Bar Close for alerts


Limitations

- The indicator is derived from the open-source Market Structure RSI by ClayeWeight
- The central structure-break accumulation methodology is adapted from the original work
- Pivot identification is based on a simple three-candle relationship
- Pivots are identified only after the required later candle has closed
- The oscillator measures broken stored structure levels rather than normal price momentum
- The Structure RSI can behave differently from a standard price RSI
- The indicator does not determine whether a structure break is genuine or false
- The indicator does not measure volume, volatility, liquidity, or trend strength
- Signals are confirmed at bar close and may occur later than temporary intrabar conditions
- A bullish signal does not guarantee that price will rise
- A bearish signal does not guarantee that price will fall
- Only one unresolved historical measurement is tracked at a time
- Not every visible signal is represented in the W/L panels
- Opposite signals do not close active measurements
- Target and stop evaluation begins on the bar after the signal
- Same-bar target and stop contact is recorded as a loss
- The W/L panels are simplified historical measurements
- The displayed percentages are not complete backtest results
- Commissions, spread, slippage, liquidity, position sizing, and execution are not included
- Historical outcomes do not imply future results
- The indicator should not be used as the sole basis for a trading decision

Price Structure RSI is an analytical and research tool.

It does not provide financial advice, guaranteed signals, guaranteed win rates, or guaranteed results.

## Source Code

````pine
// This Source Code Form is subject to the terms of the
// Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//
// Original "Market Structure RSI" by ClayeWeight.
// The pivot detection, broken-structure accumulation, cumulative
// structure total, RSI transformation, moving-average selection,
// threshold signals, and alert framework are adapted from that work.
//
// Modified and expanded by BeatingSmartMoney, 2026.
// Changes include Pine Script v6 conversion, colour presets,
// revised oscillator visuals, confirmed signals, configurable
// historical target/stop measurements, conservative outcome handling,
// and separate bullish and bearish outcome panels.

//@version=6
indicator("Price Structure RSI", overlay=false)

//=============================================================================
// INPUTS
//=============================================================================

groupPreset = "Colour Preset"
colorPreset = input.string("Dark Background", "Colour Preset", options=["Dark Background", "Light Background"], group=groupPreset)

groupStructure = "Market Structure RSI"
rsiLength = input.int(20, "RSI Length", minval=1, group=groupStructure, tooltip="Period used for the RSI calculation applied to the cumulative structure total.")
overboughtLevel = input.int(80, "Overbought Level", minval=1, maxval=100, group=groupStructure, tooltip="Upper threshold used by the bearish crossing condition.")
oversoldLevel = input.int(20, "Oversold Level", minval=0, maxval=99, group=groupStructure, tooltip="Lower threshold used by the bullish crossing condition.")
closeTypeInput = input.string("High/Low", "Structure Break Type", options=["Close", "High/Low"], group=groupStructure, tooltip="Choose whether stored structure levels are considered broken by the previous candle close or by its high and low.")

groupAverage = "Moving Average"
showAverage = input.bool(true, "Show Moving Average", group=groupAverage)
averageType = input.string("EMA", "MA Type", options=["EMA", "SMA", "WMA"], group=groupAverage)
averageLength = input.int(8, "MA Length", minval=1, group=groupAverage)

groupOutcome = "Historical Outcome Settings"
targetPercent = input.float(1.0, "Target Distance (%)", minval=0.1, step=0.1, group=groupOutcome, tooltip="Percentage distance from the confirmed signal close to the historical target level.")
stopPercent = input.float(1.0, "Stop Distance (%)", minval=0.1, step=0.1, group=groupOutcome, tooltip="Percentage distance from the confirmed signal close to the historical stop level.")
showOutcomeTables = input.bool(true, "Show Outcome Panels", group=groupOutcome, tooltip="Displays simplified historical target and stop outcomes. This is not a complete strategy backtest.")

groupTables = "Table Settings"
bullTablePositionInput = input.string("top_left", "Bull Panel Position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group=groupTables)
bearTablePositionInput = input.string("top_right", "Bear Panel Position", options=["top_left", "top_center", "top_right", "middle_left", "middle_center", "middle_right", "bottom_left", "bottom_center", "bottom_right"], group=groupTables)
bullRowOffset = input.int(0, "Bull Row Offset", minval=-2, maxval=2, group=groupTables, tooltip="Vertical position adjustment: negative moves up and positive moves down.")
bullColumnOffset = input.int(0, "Bull Column Offset", minval=-2, maxval=2, group=groupTables, tooltip="Horizontal position adjustment: negative moves left and positive moves right.")
bearRowOffset = input.int(0, "Bear Row Offset", minval=-2, maxval=2, group=groupTables, tooltip="Vertical position adjustment: negative moves up and positive moves down.")
bearColumnOffset = input.int(0, "Bear Column Offset", minval=-2, maxval=2, group=groupTables, tooltip="Horizontal position adjustment: negative moves left and positive moves right.")

//=============================================================================
// VALIDATION
//=============================================================================

if barstate.isfirst and oversoldLevel >= overboughtLevel
    runtime.error("Oversold Level must be lower than Overbought Level.")

//=============================================================================
// COLOURS
//=============================================================================

isLightPreset = colorPreset == "Light Background"

color bullColor = #00ffbb
color bearColor = #ff1100
color averageColor = #ffffff
color panelTextColor = color.white
color panelBackground = color.new(color.black, 70)

if isLightPreset
    averageColor := color.black
    panelTextColor := color.black
    panelBackground := color.new(color.white, 20)

//=============================================================================
// MARKET-STRUCTURE ENGINE
// Adapted from "Market Structure RSI" by ClayeWeight.
//=============================================================================

closeTypeBull = closeTypeInput == "Close" ? close[1] : high[1]
closeTypeBear = closeTypeInput == "Close" ? close[1] : low[1]

pivotHigh = high[3] < high[2] and high[2] > high[1]
pivotLow = low[3] > low[2] and low[2] < low[1]

var float[] storedHighs = array.new_float()
var float[] storedLows = array.new_float()
var int[] structureChanges = array.new_int()

if pivotHigh
    array.push(storedHighs, high[2])

if pivotLow
    array.push(storedLows, low[2])

f_add_to_total(direction, priceArray, changeArray, breakPrice, amount) =>
    if array.size(priceArray) > 0
        for index = array.size(priceArray) - 1 to 0
            bool isBroken = false

            if direction == 1
                isBroken := breakPrice > array.get(priceArray, index)
            else
                isBroken := breakPrice < array.get(priceArray, index)

            if isBroken
                array.remove(priceArray, index)
                array.push(changeArray, amount)
            else
                break

f_add_to_total(1, storedHighs, structureChanges, closeTypeBull, 1)
f_add_to_total(0, storedLows, structureChanges, closeTypeBear, -1)

structureTotal = array.sum(structureChanges)
structureRsi = ta.rsi(structureTotal, rsiLength)

float structureAverage = na

if averageType == "EMA"
    structureAverage := ta.ema(structureRsi, averageLength)
else if averageType == "SMA"
    structureAverage := ta.sma(structureRsi, averageLength)
else
    structureAverage := ta.wma(structureRsi, averageLength)

//=============================================================================
// CONFIRMED SIGNALS
//=============================================================================

rawBearishSignal = ta.crossunder(structureRsi, overboughtLevel)
rawBullishSignal = ta.crossover(structureRsi, oversoldLevel)

bearishSignal = rawBearishSignal and barstate.isconfirmed
bullishSignal = rawBullishSignal and barstate.isconfirmed

//=============================================================================
// SIMPLIFIED HISTORICAL TARGET / STOP MEASUREMENT
// Only one unresolved measurement is tracked at a time.
// Evaluation begins on the bar after the confirmed signal.
// When target and stop are both touched on one bar, stop takes priority.
//=============================================================================

var int bullTargetOutcomes = 0
var int bullStopOutcomes = 0
var int bearTargetOutcomes = 0
var int bearStopOutcomes = 0

var float activeEntryPrice = na
var int activeDirection = 0
var int activeEntryBar = na

bool activeOutcomeResolved = false

if activeDirection != 0 and not na(activeEntryPrice) and not na(activeEntryBar) and bar_index > activeEntryBar
    if activeDirection == 1
        float bullTargetPrice = activeEntryPrice * (1.0 + targetPercent / 100.0)
        float bullStopPrice = activeEntryPrice * (1.0 - stopPercent / 100.0)

        bool bullTargetTouched = high >= bullTargetPrice
        bool bullStopTouched = low <= bullStopPrice

        if bullStopTouched
            bullStopOutcomes += 1
            activeOutcomeResolved := true
        else if bullTargetTouched
            bullTargetOutcomes += 1
            activeOutcomeResolved := true

    else if activeDirection == -1
        float bearTargetPrice = activeEntryPrice * (1.0 - targetPercent / 100.0)
        float bearStopPrice = activeEntryPrice * (1.0 + stopPercent / 100.0)

        bool bearTargetTouched = low <= bearTargetPrice
        bool bearStopTouched = high >= bearStopPrice

        if bearStopTouched
            bearStopOutcomes += 1
            activeOutcomeResolved := true
        else if bearTargetTouched
            bearTargetOutcomes += 1
            activeOutcomeResolved := true

if activeOutcomeResolved
    activeEntryPrice := na
    activeDirection := 0
    activeEntryBar := na

if activeDirection == 0
    if bullishSignal
        activeEntryPrice := close
        activeDirection := 1
        activeEntryBar := bar_index
    else if bearishSignal
        activeEntryPrice := close
        activeDirection := -1
        activeEntryBar := bar_index

//=============================================================================
// TABLE POSITION HELPERS
//=============================================================================

f_position_row(positionText) =>
    int result = 2

    if str.contains(positionText, "top")
        result := 0
    else if str.contains(positionText, "middle")
        result := 1

    result

f_position_column(positionText) =>
    int result = 2

    if str.contains(positionText, "left")
        result := 0
    else if str.contains(positionText, "center")
        result := 1

    result

f_table_position(rowValue, columnValue) =>
    string result = position.bottom_right

    if rowValue == 0 and columnValue == 0
        result := position.top_left
    else if rowValue == 0 and columnValue == 1
        result := position.top_center
    else if rowValue == 0 and columnValue == 2
        result := position.top_right
    else if rowValue == 1 and columnValue == 0
        result := position.middle_left
    else if rowValue == 1 and columnValue == 1
        result := position.middle_center
    else if rowValue == 1 and columnValue == 2
        result := position.middle_right
    else if rowValue == 2 and columnValue == 0
        result := position.bottom_left
    else if rowValue == 2 and columnValue == 1
        result := position.bottom_center

    result

bullBaseRow = f_position_row(bullTablePositionInput)
bullBaseColumn = f_position_column(bullTablePositionInput)
bullEffectiveRow = int(math.max(0, math.min(2, bullBaseRow + bullRowOffset)))
bullEffectiveColumn = int(math.max(0, math.min(2, bullBaseColumn + bullColumnOffset)))
bullTablePosition = f_table_position(bullEffectiveRow, bullEffectiveColumn)

bearBaseRow = f_position_row(bearTablePositionInput)
bearBaseColumn = f_position_column(bearTablePositionInput)
bearEffectiveRow = int(math.max(0, math.min(2, bearBaseRow + bearRowOffset)))
bearEffectiveColumn = int(math.max(0, math.min(2, bearBaseColumn + bearColumnOffset)))
bearTablePosition = f_table_position(bearEffectiveRow, bearEffectiveColumn)

//=============================================================================
// TABLES
//=============================================================================

var table bullTable = table.new(bullTablePosition, 4, 1, bgcolor=panelBackground, border_width=1, border_color=color.black, frame_color=color.gray, frame_width=1)
var table bearTable = table.new(bearTablePosition, 4, 1, bgcolor=panelBackground, border_width=1, border_color=color.black, frame_color=color.gray, frame_width=1)

if barstate.islast
    if showOutcomeTables
        int bullCompleted = bullTargetOutcomes + bullStopOutcomes
        int bearCompleted = bearTargetOutcomes + bearStopOutcomes

        float bullTargetRatio = 0.0
        float bearTargetRatio = 0.0

        if bullCompleted > 0
            bullTargetRatio := float(bullTargetOutcomes) / float(bullCompleted) * 100.0

        if bearCompleted > 0
            bearTargetRatio := float(bearTargetOutcomes) / float(bearCompleted) * 100.0

        table.cell(bullTable, 0, 0, "Bull", bgcolor=color.new(color.gray, 80), text_color=panelTextColor, text_size=size.small)
        table.cell(bullTable, 1, 0, "W: " + str.tostring(bullTargetOutcomes), bgcolor=color.new(color.green, 80), text_color=panelTextColor, text_size=size.small)
        table.cell(bullTable, 2, 0, "L: " + str.tostring(bullStopOutcomes), bgcolor=color.new(color.red, 80), text_color=panelTextColor, text_size=size.small)
        table.cell(bullTable, 3, 0, str.tostring(bullTargetRatio, "#.##") + "%", bgcolor=color.new(color.gray, 80), text_color=panelTextColor, text_size=size.small)

        table.cell(bearTable, 0, 0, "Bear", bgcolor=color.new(color.gray, 80), text_color=panelTextColor, text_size=size.small)
        table.cell(bearTable, 1, 0, "W: " + str.tostring(bearTargetOutcomes), bgcolor=color.new(color.green, 80), text_color=panelTextColor, text_size=size.small)
        table.cell(bearTable, 2, 0, "L: " + str.tostring(bearStopOutcomes), bgcolor=color.new(color.red, 80), text_color=panelTextColor, text_size=size.small)
        table.cell(bearTable, 3, 0, str.tostring(bearTargetRatio, "#.##") + "%", bgcolor=color.new(color.gray, 80), text_color=panelTextColor, text_size=size.small)
    else
        table.clear(bullTable, 0, 0, 3, 0)
        table.clear(bearTable, 0, 0, 3, 0)

//=============================================================================
// PLOTS
//=============================================================================

color rsiLineColor = color.gray

if structureRsi > overboughtLevel
    rsiLineColor := bearColor
else if structureRsi < oversoldLevel
    rsiLineColor := bullColor

rsiPlot = plot(structureRsi, color=color.new(rsiLineColor, 20), linewidth=2, title="Structure RSI")
plot(showAverage ? structureAverage : na, color=averageColor, title="RSI Moving Average", linewidth=1, style=plot.style_linebr)

plotshape(bearishSignal, size=size.tiny, style=shape.square, location=location.top, color=bearColor, title="Bearish Signal")
plotshape(bullishSignal, size=size.tiny, style=shape.square, location=location.bottom, color=bullColor, title="Bullish Signal")

overboughtLine = hline(overboughtLevel, "Overbought Level", color=color.new(bearColor, 50), linestyle=hline.style_dashed)
oversoldLine = hline(oversoldLevel, "Oversold Level", color=color.new(bullColor, 50), linestyle=hline.style_dashed)
hline(50, "Midline", color=color.new(color.gray, 70), linestyle=hline.style_dotted)

fill(overboughtLine, oversoldLine, color.new(color.gray, 95), title="Background Fill")

midPlot = plot(50, color=na, display=display.none)
fill(rsiPlot, midPlot, 100, 50, top_color=color.new(bearColor, 50), bottom_color=color.new(bearColor, 100), title="Overbought Gradient Fill")
fill(rsiPlot, midPlot, 50, 0, top_color=color.new(bullColor, 100), bottom_color=color.new(bullColor, 50), title="Oversold Gradient Fill")

color dynamicBackground = na

if structureRsi > overboughtLevel
    dynamicBackground := color.new(bearColor, 90)
else if structureRsi < oversoldLevel
    dynamicBackground := color.new(bullColor, 90)

bgcolor(dynamicBackground)

//=============================================================================
// ALERTS
//=============================================================================

alertcondition(bearishSignal, "Bearish Signal", "Price Structure RSI crossed below the overbought level on a confirmed bar.")
alertcondition(bullishSignal, "Bullish Signal", "Price Structure RSI crossed above the oversold level on a confirmed bar.")
````
