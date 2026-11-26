# Multi-Timeframe ATR Stop & Contract Risk Table

- url: https://www.tradingview.com/script/zX87afUe-Multi-Timeframe-ATR-Stop-Contract-Risk-Table/
- type: indicator
- pine_id: PUB;321e12f41ad949d0a8f333e9a8f403f5
- version: 3.0

## Description

Summary

The Multi-Timeframe ATR Stop & Contract Risk Table is an educational risk-management tool that displays Average True Range (ATR) values from multiple lower timeframes in a single table. It converts ATR into points, ticks, and estimated dollar values to help traders compare current market volatility across intraday timeframes.

The indicator is intended to assist with trade planning and position sizing. It does not generate trade signals or recommend entries or exits.

Description

Average True Range (ATR) is a widely used volatility measurement that estimates the average movement of price over a specified lookback period.

This script displays ATR values from the following timeframes:

1 Minute
2 Minute
3 Minute
5 Minute

For each timeframe the table displays:

ATR in Points
ATR converted to Ticks
Estimated Full-Size Contract Dollar Value
Estimated Micro Contract Dollar Value

The calculations can use the chart symbol's point value automatically or a manually specified value when desired.

The indicator is designed to reduce mental calculations when comparing potential stop distances across multiple intraday timeframes.

Features
Multi-timeframe ATR calculations
Independent ATR length
Multiple ATR smoothing methods
RMA
SMA
EMA
WMA
Automatic symbol point-value detection
Optional manual point-value override
Estimated dollar risk for full-size contracts
Estimated dollar risk for micro contracts
Adjustable ATR multiplier
Adjustable contract quantities
Compact table positioned on the chart
Tooltips throughout the settings and table
How to Use
Select an ATR length appropriate for your market.
Choose the desired ATR smoothing method.
Confirm or manually enter the contract point value if necessary.
Adjust the ATR multiplier if your trading plan uses stops based on a fraction or multiple of ATR.
Use the table to compare recent volatility between the 1-, 2-, 3-, and 5-minute timeframes.

The displayed values may be useful when estimating stop distances and approximate monetary exposure before entering a trade.

Educational Notes

Average True Range measures recent volatility.

ATR does not indicate:

market direction
trend strength
probability of success
optimal entry locations

ATR should be interpreted together with the user's own market analysis and risk-management methodology.

Intended Use

This script is intended for educational and informational purposes.

It assists traders by presenting volatility information in a compact format that may reduce manual calculations during trade planning.

Limitations
Dollar values are estimates based on the selected point value and contract quantity.
Actual fills, slippage, commissions, and execution costs are not included.
Different markets may use different contract specifications.
ATR is a lagging volatility measure and should not be interpreted as a predictive indicator.
Originality Statement

This indicator was developed as an original implementation using Pine Script® v6.

The calculations use publicly documented ATR methodology available within TradingView's Pine Script® environment. The implementation, table layout, user interface, conversion logic, and visualization were written specifically for this script and are not copied from another published TradingView indicator.

## Source Code

````pine
//@version=6
indicator(
     title = "Multi-Timeframe ATR Stop & Contract Risk Table",
     shorttitle = "ATR Risk",
     overlay = true
)

// ==============================================================================
//  MULTI-TIMEFRAME ATR STOP & CONTRACT RISK TABLE
//
//  Displays ATR from four user-selected timeframes in:
//  - Points
//  - Ticks
//  - Full-size contract dollar value
//  - Micro-equivalent contract dollar value
//
//  Each timeframe is independently configurable through input.timeframe().
// ==============================================================================


// ==============================================================================
//  1. TIMEFRAME SETTINGS
// ==============================================================================

string GROUP_01 = "1. Timeframe Settings"

bool enableTF1 = input.bool(
     true,
     "Enable Timeframe 1",
     group = GROUP_01,
     tooltip = "Displays the first configurable ATR timeframe."
)

string timeframe1 = input.timeframe(
     "1",
     "Timeframe 1",
     group = GROUP_01,
     tooltip = "Select any TradingView-supported timeframe."
)

bool enableTF2 = input.bool(
     true,
     "Enable Timeframe 2",
     group = GROUP_01,
     tooltip = "Displays the second configurable ATR timeframe."
)

string timeframe2 = input.timeframe(
     "2",
     "Timeframe 2",
     group = GROUP_01,
     tooltip = "Select any TradingView-supported timeframe."
)

bool enableTF3 = input.bool(
     true,
     "Enable Timeframe 3",
     group = GROUP_01,
     tooltip = "Displays the third configurable ATR timeframe."
)

string timeframe3 = input.timeframe(
     "3",
     "Timeframe 3",
     group = GROUP_01,
     tooltip = "Select any TradingView-supported timeframe."
)

bool enableTF4 = input.bool(
     true,
     "Enable Timeframe 4",
     group = GROUP_01,
     tooltip = "Displays the fourth configurable ATR timeframe."
)

string timeframe4 = input.timeframe(
     "5",
     "Timeframe 4",
     group = GROUP_01,
     tooltip = "Select any TradingView-supported timeframe."
)


// ==============================================================================
//  2. ATR SETTINGS
// ==============================================================================

string GROUP_02 = "2. ATR Settings"

int atrLength = input.int(
     14,
     "ATR Length",
     minval = 1,
     maxval = 500,
     group = GROUP_02,
     tooltip = "ATR calculation length used independently on each selected timeframe."
)

string atrSmoothing = input.string(
     "RMA",
     "ATR Smoothing",
     options = ["RMA", "SMA", "EMA", "WMA"],
     group = GROUP_02,
     tooltip = "RMA matches TradingView's standard ATR smoothing."
)

float stopMultiplier = input.float(
     1.0,
     "ATR Stop Multiplier",
     minval = 0.10,
     maxval = 10.0,
     step = 0.10,
     group = GROUP_02,
     tooltip = "Multiplies each ATR before conversion to points, ticks, and dollars."
)


// ==============================================================================
//  3. CONTRACT VALUE SETTINGS
// ==============================================================================

string GROUP_03 = "3. Contract Value Settings"

bool useSymbolPointValue = input.bool(
     true,
     "Use Symbol Point Value",
     group = GROUP_03,
     tooltip = "Uses syminfo.pointvalue for the chart symbol."
)

float manualPointValue = input.float(
     20.0,
     "Manual Full-Size Dollar Value Per Point",
     minval = 0.000001,
     step = 0.25,
     group = GROUP_03,
     tooltip = "Used only when Use Symbol Point Value is disabled."
)

int contractQuantity = input.int(
     1,
     "Full-Size Contract Quantity",
     minval = 1,
     maxval = 1000,
     group = GROUP_03,
     tooltip = "Full-size dollar values are multiplied by this quantity."
)

bool useOneTenthMicroValue = input.bool(
     true,
     "Micro Uses 1/10 Point Value",
     group = GROUP_03,
     tooltip = "Uses one-tenth of the full-size point value. This matches common pairs such as NQ/MNQ and ES/MES."
)

float manualMicroPointValue = input.float(
     2.0,
     "Manual Micro Dollar Value Per Point",
     minval = 0.000001,
     step = 0.25,
     group = GROUP_03,
     tooltip = "Used when Micro Uses 1/10 Point Value is disabled."
)

int microContractQuantity = input.int(
     1,
     "Micro Contract Quantity",
     minval = 1,
     maxval = 1000,
     group = GROUP_03,
     tooltip = "Micro-equivalent dollar values are multiplied by this quantity."
)


// ==============================================================================
//  4. TABLE SETTINGS
// ==============================================================================

string GROUP_04 = "4. Table Settings"

bool showTable = input.bool(
     true,
     "Show ATR Table",
     group = GROUP_04,
     tooltip = "Displays the ATR stop and contract-risk table."
)

string tablePositionInput = input.string(
     "Middle Right",
     "Table Position",
     options = [
         "Top Left",
         "Top Center",
         "Top Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"
     ],
     group = GROUP_04,
     tooltip = "Selects the table location."
)

string textSizeInput = input.string(
     "Small",
     "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = GROUP_04,
     tooltip = "Controls table text size."
)

int pointsDecimals = input.int(
     2,
     "Points Decimals",
     minval = 0,
     maxval = 6,
     group = GROUP_04,
     tooltip = "Decimal places shown for ATR points."
)

int dollarDecimals = input.int(
     2,
     "Dollar Decimals",
     minval = 0,
     maxval = 2,
     group = GROUP_04,
     tooltip = "Decimal places shown for dollar values."
)


// ==============================================================================
//  HELPER FUNCTIONS
// ==============================================================================

f_trueRange() =>
    math.max(
         high - low,
         math.max(
             math.abs(high - close[1]),
             math.abs(low - close[1])
         )
    )

f_atr(int length, string smoothing) =>
    float trValue = f_trueRange()

    // All smoothing functions execute on every calculation.
    // The selected method is chosen only after all series are calculated.
    float atrRma = ta.rma(trValue, length)
    float atrSma = ta.sma(trValue, length)
    float atrEma = ta.ema(trValue, length)
    float atrWma = ta.wma(trValue, length)

    switch smoothing
        "SMA" => atrSma
        "EMA" => atrEma
        "WMA" => atrWma
        => atrRma

f_textSize(string value) =>
    switch value
        "Tiny" => size.tiny
        "Normal" => size.normal
        "Large" => size.large
        => size.small

f_tablePosition(string value) =>
    switch value
        "Top Left" => position.top_left
        "Top Center" => position.top_center
        "Top Right" => position.top_right
        "Middle Left" => position.middle_left
        "Middle Center" => position.middle_center
        "Bottom Left" => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right" => position.bottom_right
        => position.middle_right

f_decimalPattern(int decimals) =>
    switch decimals
        0 => "#"
        1 => "#.0"
        2 => "#.00"
        3 => "#.000"
        4 => "#.0000"
        5 => "#.00000"
        => "#.000000"

f_formatPoints(float value) =>
    na(value) ? "—" : str.tostring(value, f_decimalPattern(pointsDecimals))

f_formatTicks(float value) =>
    na(value) ? "—" : str.tostring(math.round(value), "#")

f_formatDollars(float value) =>
    na(value) ? "—" : "$" + str.tostring(value, f_decimalPattern(dollarDecimals))

f_timeframeLabel(string timeframeValue) =>
    timeframeValue == "1D" or timeframeValue == "D" ? "1D" :
     timeframeValue == "1W" or timeframeValue == "W" ? "1W" :
     timeframeValue == "1M" or timeframeValue == "M" ? "1M" :
     timeframeValue

f_atrForTimeframe(string timeframeValue) =>
    request.security(
         syminfo.tickerid,
         timeframeValue,
         f_atr(atrLength, atrSmoothing),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
    )


// ==============================================================================
//  CONFIGURABLE MULTI-TIMEFRAME ATR CALCULATIONS
// ==============================================================================

float atrTF1 = f_atrForTimeframe(timeframe1)
float atrTF2 = f_atrForTimeframe(timeframe2)
float atrTF3 = f_atrForTimeframe(timeframe3)
float atrTF4 = f_atrForTimeframe(timeframe4)

float pointValue = useSymbolPointValue ? syminfo.pointvalue : manualPointValue
float microPointValue = useOneTenthMicroValue ? pointValue / 10.0 : manualMicroPointValue
float minimumTick = syminfo.mintick
float fullTickValue = minimumTick * pointValue
float microTickValue = minimumTick * microPointValue

float stopTF1Points = atrTF1 * stopMultiplier
float stopTF2Points = atrTF2 * stopMultiplier
float stopTF3Points = atrTF3 * stopMultiplier
float stopTF4Points = atrTF4 * stopMultiplier

float stopTF1Ticks = minimumTick > 0 ? stopTF1Points / minimumTick : na
float stopTF2Ticks = minimumTick > 0 ? stopTF2Points / minimumTick : na
float stopTF3Ticks = minimumTick > 0 ? stopTF3Points / minimumTick : na
float stopTF4Ticks = minimumTick > 0 ? stopTF4Points / minimumTick : na

float stopTF1FullDollars = stopTF1Points * pointValue * contractQuantity
float stopTF2FullDollars = stopTF2Points * pointValue * contractQuantity
float stopTF3FullDollars = stopTF3Points * pointValue * contractQuantity
float stopTF4FullDollars = stopTF4Points * pointValue * contractQuantity

float stopTF1MicroDollars = stopTF1Points * microPointValue * microContractQuantity
float stopTF2MicroDollars = stopTF2Points * microPointValue * microContractQuantity
float stopTF3MicroDollars = stopTF3Points * microPointValue * microContractQuantity
float stopTF4MicroDollars = stopTF4Points * microPointValue * microContractQuantity


// ==============================================================================
//  TABLE
// ==============================================================================

var table atrTable = table.new(
     f_tablePosition(tablePositionInput),
     5,
     9,
     border_width = 1
)

f_cell(
     int column,
     int row,
     string cellText,
     color backgroundColor,
     string tooltipText
 ) =>
    table.cell(
         atrTable,
         column,
         row,
         cellText,
         bgcolor = backgroundColor,
         text_color = color.white,
         text_size = f_textSize(textSizeInput),
         tooltip = tooltipText
    )

f_timeframeRow(
     int row,
     bool enabled,
     string timeframeValue,
     float rawAtr,
     float stopPoints,
     float stopTicks,
     float fullDollars,
     float microDollars,
     color labelColor,
     color valueColor
 ) =>
    string timeframeText = enabled ? f_timeframeLabel(timeframeValue) : "OFF"
    string rawTooltip = enabled ? "Raw ATR: " + f_formatPoints(rawAtr) : "This timeframe row is disabled."

    f_cell(0, row, timeframeText, labelColor, "Configured ATR timeframe.")
    f_cell(1, row, enabled ? f_formatPoints(stopPoints) : "—", valueColor, rawTooltip)
    f_cell(2, row, enabled ? f_formatTicks(stopTicks) : "—", valueColor, "Minimum tick: " + str.tostring(minimumTick, format.mintick))
    f_cell(3, row, enabled ? f_formatDollars(fullDollars) : "—", valueColor, str.tostring(contractQuantity) + " full-size contract(s)")
    f_cell(4, row, enabled ? f_formatDollars(microDollars) : "—", valueColor, str.tostring(microContractQuantity) + " micro contract(s)")

if barstate.islast
    if showTable
        color headerColor = color.new(color.silver, 65)
        color labelColor = color.new(color.gray, 82)
        color valueColor = color.new(color.black, 0)
        color infoColor = color.new(color.blue, 82)

        f_cell(0, 0, "TF", headerColor, "User-selected ATR timeframe.")
        f_cell(1, 0, "POINTS", headerColor, "ATR multiplied by the selected stop multiplier.")
        f_cell(2, 0, "TICKS", headerColor, "ATR points divided by the symbol's minimum tick.")
        f_cell(3, 0, "FULL $", headerColor, "Full-size estimated dollar risk.")
        f_cell(4, 0, "MICRO $", headerColor, "Micro-equivalent estimated dollar risk.")

        f_timeframeRow(1, enableTF1, timeframe1, atrTF1, stopTF1Points, stopTF1Ticks, stopTF1FullDollars, stopTF1MicroDollars, labelColor, valueColor)
        f_timeframeRow(2, enableTF2, timeframe2, atrTF2, stopTF2Points, stopTF2Ticks, stopTF2FullDollars, stopTF2MicroDollars, labelColor, valueColor)
        f_timeframeRow(3, enableTF3, timeframe3, atrTF3, stopTF3Points, stopTF3Ticks, stopTF3FullDollars, stopTF3MicroDollars, labelColor, valueColor)
        f_timeframeRow(4, enableTF4, timeframe4, atrTF4, stopTF4Points, stopTF4Ticks, stopTF4FullDollars, stopTF4MicroDollars, labelColor, valueColor)

        f_cell(0, 5, "MULT", infoColor, "Selected ATR stop multiplier.")
        f_cell(1, 5, str.tostring(stopMultiplier, "#.00") + "×", infoColor, "All enabled rows use this multiplier.")
        f_cell(2, 5, "FULL QTY", infoColor, "Full-size contract quantity.")
        f_cell(3, 5, str.tostring(contractQuantity), infoColor, "Full-size estimated risk includes this quantity.")
        f_cell(4, 5, "MICRO QTY " + str.tostring(microContractQuantity), infoColor, "Micro estimated risk includes this quantity.")

        f_cell(0, 6, "$ / PT", infoColor, "Full-size dollar value of one point.")
        f_cell(1, 6, f_formatDollars(pointValue), infoColor, useSymbolPointValue ? "Using syminfo.pointvalue." : "Using manual full-size point value.")
        f_cell(2, 6, "$ / TICK", infoColor, "Dollar value of one minimum tick.")
        f_cell(3, 6, f_formatDollars(fullTickValue), infoColor, "Full-size tick value.")
        f_cell(4, 6, f_formatDollars(microTickValue), infoColor, "Micro-equivalent tick value.")

        f_cell(0, 7, "MICRO", infoColor, "Micro-equivalent point-value assumptions.")
        f_cell(1, 7, f_formatDollars(microPointValue) + "/pt", infoColor, useOneTenthMicroValue ? "Using one-tenth of the full-size point value." : "Using manual micro point value.")
        f_cell(2, 7, "RATIO", infoColor, "Full-size to micro point-value ratio.")
        f_cell(3, 7, str.tostring(pointValue / microPointValue, "#.##") + ":1", infoColor, "Calculated point-value ratio.")
        f_cell(4, 7, useOneTenthMicroValue ? "AUTO" : "MANUAL", infoColor, "Micro point-value mode.")

        f_cell(0, 8, "SYMBOL", labelColor, "Current chart symbol.")
        f_cell(1, 8, syminfo.ticker, valueColor, syminfo.description)
        f_cell(2, 8, "ATR LEN", labelColor, "ATR calculation length.")
        f_cell(3, 8, str.tostring(atrLength), valueColor, atrSmoothing + " smoothing.")
        f_cell(4, 8, tablePositionInput, labelColor, "Current table position.")
    else
        table.clear(atrTable, 0, 0, 4, 8)


// ==============================================================================
//  DATA WINDOW OUTPUTS
// ==============================================================================

plot(enableTF1 ? stopTF1Points : na, "TF1 ATR Stop Points", color = color.new(color.blue, 100), display = display.data_window)
plot(enableTF2 ? stopTF2Points : na, "TF2 ATR Stop Points", color = color.new(color.blue, 100), display = display.data_window)
plot(enableTF3 ? stopTF3Points : na, "TF3 ATR Stop Points", color = color.new(color.blue, 100), display = display.data_window)
plot(enableTF4 ? stopTF4Points : na, "TF4 ATR Stop Points", color = color.new(color.blue, 100), display = display.data_window)

plot(enableTF1 ? stopTF1Ticks : na, "TF1 ATR Stop Ticks", color = color.new(color.orange, 100), display = display.data_window)
plot(enableTF2 ? stopTF2Ticks : na, "TF2 ATR Stop Ticks", color = color.new(color.orange, 100), display = display.data_window)
plot(enableTF3 ? stopTF3Ticks : na, "TF3 ATR Stop Ticks", color = color.new(color.orange, 100), display = display.data_window)
plot(enableTF4 ? stopTF4Ticks : na, "TF4 ATR Stop Ticks", color = color.new(color.orange, 100), display = display.data_window)

plot(enableTF1 ? stopTF1FullDollars : na, "TF1 Full Contract Dollars", color = color.new(color.green, 100), display = display.data_window)
plot(enableTF2 ? stopTF2FullDollars : na, "TF2 Full Contract Dollars", color = color.new(color.green, 100), display = display.data_window)
plot(enableTF3 ? stopTF3FullDollars : na, "TF3 Full Contract Dollars", color = color.new(color.green, 100), display = display.data_window)
plot(enableTF4 ? stopTF4FullDollars : na, "TF4 Full Contract Dollars", color = color.new(color.green, 100), display = display.data_window)

plot(enableTF1 ? stopTF1MicroDollars : na, "TF1 Micro Contract Dollars", color = color.new(color.purple, 100), display = display.data_window)
plot(enableTF2 ? stopTF2MicroDollars : na, "TF2 Micro Contract Dollars", color = color.new(color.purple, 100), display = display.data_window)
plot(enableTF3 ? stopTF3MicroDollars : na, "TF3 Micro Contract Dollars", color = color.new(color.purple, 100), display = display.data_window)
plot(enableTF4 ? stopTF4MicroDollars : na, "TF4 Micro Contract Dollars", color = color.new(color.purple, 100), display = display.data_window)
````
