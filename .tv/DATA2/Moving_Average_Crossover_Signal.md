<!-- tradingview-pine-id: PUB;40b88994981f4f2482d04a085fa8dd84 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Moving Average Crossover Signal

Source: https://www.tradingview.com/script/yACBNVlg-Moving-Average-Crossover-Signal/

## Description

[image]https://www.tradingview.com/x/yQc7JVek/[/image]
Moving Average Crossover Signal

This is a customizable multi-symbol, multi-timeframe indicator that provides a compact visual signal based on the relationship between two user-defined moving averages. It is designed to function as a simple “red light” or “green light” for the current trend, allowing moving average conditions to be monitored without displaying the moving averages themselves. The signal can also track a ticker different from the active chart symbol, making it possible to monitor another market without keeping that ticker’s chart open.

The indicator calculates two independently configurable moving averages on a selected ticker and timeframe, then displays a persistent signal icon in a user-selected area of the chart. Instead of plotting historical crossover markers or moving average lines, it provides a clean at-a-glance indication of whether the configured MA condition is currently active.

Signal Logic

Two signal modes are available:

[*]Crossover Only — the signal is active while Moving Average 1 is above Moving Average 2.
[*]Crossover + Both MAs Sloping Up — the signal is active only while Moving Average 1 is above Moving Average 2 and both moving averages are rising over the selected slope lookback period.

The signal icon uses independently configurable colors for active, inactive, and unavailable-data conditions.

Ticker and Timeframe Selection

The signal can be calculated from a ticker that is different from the symbol currently displayed on the chart. Leaving the ticker input blank uses the active chart symbol.

A separate Signal Timeframe input allows the moving averages and signal logic to be calculated using a timeframe independent of the chart timeframe. Leaving the timeframe set to the chart interval uses the current chart timeframe.

This makes it possible, for example, to monitor a daily moving average condition while viewing an intraday chart, or to monitor one symbol's higher timeframe trend while analyzing another symbol.

Moving Average Configuration

Both moving averages can be configured independently with:

[*]SMA
[*]EMA
[*]WMA
[*]RMA
[*]HMA

The slope-filtered mode also includes a configurable lookback period that determines whether each moving average is considered to be rising.

Signal Display

The on-chart signal is designed to remain compact and unobtrusive. Display options include:

[*]Multiple signal icon styles
[*]Active, inactive, and no-data colors
[*]Automatic display of the selected ticker
[*]Custom text that can override the ticker label
[*]Signal icon before or after the display text
[*]Independent icon and text sizes
[*]Nine standard chart locations
[*]Additional spacer rows above or below the signal for finer vertical positioning
[*]Customizable panel background, including full transparency

The indicator does not plot the moving averages themselves, keeping the chart free of additional lines.

Alerts

A TradingView alert condition is included for the actual bullish moving average crossover event.

When Crossover + Both MAs Sloping Up is selected, the crossover must also occur while both moving averages satisfy the selected upward-slope condition.

This keeps the persistent visual signal separate from the crossover event: the icon shows the current state of the configured condition, while the alert identifies the point at which a qualifying crossover occurs.

Usage and Limitations

For the most reliable results, use a Signal Timeframe that is the same as or higher than the chart timeframe.

Lower timeframe selections may not capture every crossover that occurs between chart bars, so signals can be missed.

Higher timeframe signals may also change while that candle is still forming, so they should be considered provisional until the selected timeframe closes.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0
// © cmacktrades

//@version=6
indicator("Moving Average Crossover Signal", shorttitle="MA Crossover Signal", overlay=true)

//=============================================================================
// INPUT GROUPS
//=============================================================================

string GROUP_TICKER  = "Ticker"
string GROUP_MA1     = "Moving Average 1"
string GROUP_MA2     = "Moving Average 2"
string GROUP_SIGNAL  = "Signal Conditions"
string GROUP_DISPLAY = "Signal Display"

//=============================================================================
// TICKER / SOURCE / TIMEFRAME
//=============================================================================

string tickerInput = input.symbol(
     "",
     "Signal Ticker",
     group=GROUP_TICKER,
     tooltip="Leave blank to use the current chart symbol."
     )

string signalTimeframe = input.timeframe(
     "",
     "Signal Timeframe",
     group=GROUP_TICKER,
     tooltip="Select the timeframe used to calculate the signal. Leave on the chart timeframe to use the current chart interval."
     )

string sourceInput = input.string(
     "Close",
     "Price Source",
     options=["Open", "High", "Low", "Close", "HL2", "HLC3", "OHLC4"],
     group=GROUP_TICKER
     )

//=============================================================================
// MOVING AVERAGE 1
//=============================================================================

string ma1Type = input.string(
     "SMA",
     "MA 1 Type",
     options=["SMA", "EMA", "WMA", "RMA", "HMA"],
     group=GROUP_MA1
     )

int ma1Length = input.int(
     10,
     "MA 1 Length",
     minval=1,
     group=GROUP_MA1
     )

//=============================================================================
// MOVING AVERAGE 2
//=============================================================================

string ma2Type = input.string(
     "SMA",
     "MA 2 Type",
     options=["SMA", "EMA", "WMA", "RMA", "HMA"],
     group=GROUP_MA2
     )

int ma2Length = input.int(
     20,
     "MA 2 Length",
     minval=1,
     group=GROUP_MA2
     )

//=============================================================================
// SIGNAL CONDITIONS
//=============================================================================

string signalMode = input.string(
     "Crossover Only",
     "Signal Mode",
     options=[
         "Crossover Only",
         "Crossover + Both MAs Sloping Up"
     ],
     group=GROUP_SIGNAL,
     tooltip=
         "Crossover Only: Signal is green while MA 1 is above MA 2.\n\n" +
         "Crossover + Both MAs Sloping Up: Signal is green while MA 1 is above MA 2 " +
         "and both moving averages are rising."
     )

int slopeLookback = input.int(
     1,
     "Slope Lookback Bars",
     minval=1,
     group=GROUP_SIGNAL,
     tooltip=
         "An MA is considered to be sloping up when its current value " +
         "is above its value this many bars ago on the selected signal timeframe."
     )

//=============================================================================
// SIGNAL DISPLAY
//=============================================================================

string displayPosition = input.string(
     "Top Right",
     "Display Position",
     options=[
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
     group=GROUP_DISPLAY
     )

//-----------------------------------------------------------------------------
// SIGNAL ICON
//-----------------------------------------------------------------------------

string signalIcon = input.string(
     "●",
     "Signal Icon",
     options=[
         "⬤",
         "●",    
         "■",
         "◆",
         "★",
         "✦"
     ],
     group=GROUP_DISPLAY
     )

string signalIconPosition = input.string(
     "After Text",
     "Signal Icon Position",
     options=[
         "Before Text",
         "After Text"
     ],
     group=GROUP_DISPLAY,
     tooltip="Choose whether the signal icon appears before or after the ticker/custom display text."
     )

//-----------------------------------------------------------------------------
// DISPLAY TEXT
//-----------------------------------------------------------------------------

bool showTicker = input.bool(
     true,
     "Show Ticker / Text",
     group=GROUP_DISPLAY
     )

string customDisplayText = input.string(
     "",
     "Custom Display Text",
     group=GROUP_DISPLAY,
     tooltip=
         "Optional text to display instead of the selected ticker. " +
         "Leave blank to automatically display the ticker symbol."
     )

//-----------------------------------------------------------------------------
// SIZE DROPDOWNS
//-----------------------------------------------------------------------------

string iconSize = input.string(
     size.small,
     "Signal Icon Size",
     options=[
         size.tiny,
         size.small,
         size.normal,
         size.large,
         size.huge
     ],
     group=GROUP_DISPLAY
     )

string displayTextSize = input.string(
     size.small,
     "Display Text Size",
     options=[
         size.tiny,
         size.small,
         size.normal,
         size.large,
         size.huge
     ],
     group=GROUP_DISPLAY
     )

//-----------------------------------------------------------------------------
// POSITION OFFSET / SPACER LINES
//-----------------------------------------------------------------------------

int linesAbove = input.int(
     0,
     "Lines Above",
     minval=0,
     maxval=20,
     group=GROUP_DISPLAY,
     tooltip=
         "Adds blank rows above the signal. " +
         "With a Top position, this moves the signal farther down."
     )

int linesBelow = input.int(
     0,
     "Lines Below",
     minval=0,
     maxval=20,
     group=GROUP_DISPLAY,
     tooltip=
         "Adds blank rows below the signal. " +
         "With a Bottom position, this moves the signal farther up."
     )

//-----------------------------------------------------------------------------
// COLORS
//-----------------------------------------------------------------------------

color activeSignalColor = input.color(
     color.green,
     "Active Signal Color",
     group=GROUP_DISPLAY
     )

color inactiveSignalColor = input.color(
     color.red,
     "Inactive Signal Color",
     group=GROUP_DISPLAY
     )

color noDataSignalColor = input.color(
     color.gray,
     "No Data Signal Color",
     group=GROUP_DISPLAY
     )

color displayTextColor = input.color(
     color.white,
     "Display Text Color",
     group=GROUP_DISPLAY
     )

color panelColor = input.color(
     color.new(color.black, 100),
     "Panel Background",
     group=GROUP_DISPLAY
     )

//=============================================================================
// FUNCTIONS
//=============================================================================

getSource(string sourceType) =>
    switch sourceType
        "Open"  => open
        "High"  => high
        "Low"   => low
        "HL2"   => hl2
        "HLC3"  => hlc3
        "OHLC4" => ohlc4
        => close

getMA(float src, int length, string maType) =>
    switch maType
        "SMA" => ta.sma(src, length)
        "EMA" => ta.ema(src, length)
        "WMA" => ta.wma(src, length)
        "RMA" => ta.rma(src, length)
        "HMA" => ta.hma(src, length)
        => ta.ema(src, length)

calculateMASignal() =>
    float src = getSource(sourceInput)

    float ma1 = getMA(src, ma1Length, ma1Type)
    float ma2 = getMA(src, ma2Length, ma2Type)

    bool bullishState = ma1 > ma2
    bool crossoverEvent = ta.crossover(ma1, ma2)

    bool ma1SlopingUp = ma1 > ma1[slopeLookback]
    bool ma2SlopingUp = ma2 > ma2[slopeLookback]

    bool bothSlopingUp = ma1SlopingUp and ma2SlopingUp

    [ma1, ma2, bullishState, crossoverEvent, bothSlopingUp]

//=============================================================================
// SELECT REQUESTED TICKER
//=============================================================================

string requestedTicker =
     tickerInput == "" ? syminfo.tickerid : tickerInput

//=============================================================================
// REQUEST SELECTED TICKER / TIMEFRAME DATA
//=============================================================================

[requestedMA1, requestedMA2, bullishMAState, crossoverEvent, bothMAsSlopingUp] = request.security(
     requestedTicker,
     signalTimeframe,
     calculateMASignal(),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
     )

//=============================================================================
// SIGNAL LOGIC
//=============================================================================

bool slopeFilterRequired =
     signalMode == "Crossover + Both MAs Sloping Up"

bool haveData =
     not na(requestedMA1) and
     not na(requestedMA2)

// Active signal:
//
// Mode 1:
// MA 1 > MA 2
//
// Mode 2:
// MA 1 > MA 2 AND both MAs are sloping upward.

bool signalActive =
     haveData and
     bullishMAState and
     (not slopeFilterRequired or bothMAsSlopingUp)

// Actual crossover event remains separate for alerts.

bool crossoverSignal =
     crossoverEvent and
     (not slopeFilterRequired or bothMAsSlopingUp)

//=============================================================================
// TABLE POSITION
//=============================================================================

string tablePosition = switch displayPosition
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right

//=============================================================================
// DISPLAY VALUES
//=============================================================================

// Default text is the selected ticker.
// Custom Display Text overrides it when supplied.

string defaultDisplayText =
     tickerInput == "" ? syminfo.ticker : tickerInput

string signalDisplayText =
     customDisplayText != "" ? customDisplayText : defaultDisplayText

color currentSignalColor =
     not haveData
     ? noDataSignalColor
     : signalActive
     ? activeSignalColor
     : inactiveSignalColor

// Determine which column contains the icon and which contains the text.

bool iconBeforeText =
     signalIconPosition == "Before Text"

int iconColumn =
     iconBeforeText ? 0 : 1

int textColumn =
     iconBeforeText ? 1 : 0

//=============================================================================
// TABLE DIMENSIONS
//=============================================================================

int totalRows = linesAbove + 1 + linesBelow
int signalRow = linesAbove

//=============================================================================
// CREATE SIGNAL TABLE
//=============================================================================

var table signalTable = table.new(
     tablePosition,
     2,
     totalRows,
     bgcolor=panelColor
     )

//=============================================================================
// UPDATE SIGNAL TABLE
//=============================================================================

if barstate.islast

    //-------------------------------------------------------------------------
    // BLANK LINES ABOVE
    //-------------------------------------------------------------------------

    if linesAbove > 0
        for row = 0 to linesAbove - 1
            table.cell(
                 signalTable,
                 0,
                 row,
                 " ",
                 text_size=size.normal,
                 bgcolor=panelColor
                 )

            table.cell(
                 signalTable,
                 1,
                 row,
                 " ",
                 text_size=size.normal,
                 bgcolor=panelColor
                 )

    //-------------------------------------------------------------------------
    // DISPLAY TEXT
    //-------------------------------------------------------------------------

    if showTicker
        table.cell(
             signalTable,
             textColumn,
             signalRow,
             signalDisplayText,
             text_color=displayTextColor,
             text_size=displayTextSize,
             bgcolor=panelColor,
             text_halign=iconBeforeText ? text.align_left : text.align_right,
             text_valign=text.align_center
             )
    else
        table.cell(
             signalTable,
             textColumn,
             signalRow,
             "",
             text_size=displayTextSize,
             bgcolor=panelColor
             )

    //-------------------------------------------------------------------------
    // SIGNAL ICON
    //-------------------------------------------------------------------------

    table.cell(
         signalTable,
         iconColumn,
         signalRow,
         signalIcon,
         text_color=currentSignalColor,
         text_size=iconSize,
         bgcolor=panelColor,
         text_halign=text.align_center,
         text_valign=text.align_center
         )

    //-------------------------------------------------------------------------
    // BLANK LINES BELOW
    //-------------------------------------------------------------------------

    if linesBelow > 0
        for row = signalRow + 1 to totalRows - 1
            table.cell(
                 signalTable,
                 0,
                 row,
                 " ",
                 text_size=size.normal,
                 bgcolor=panelColor
                 )

            table.cell(
                 signalTable,
                 1,
                 row,
                 " ",
                 text_size=size.normal,
                 bgcolor=panelColor
                 )

//=============================================================================
// ALERT
//=============================================================================

alertcondition(
     crossoverSignal,
     title="MA Bullish Crossover Signal",
     message="The selected ticker produced the configured bullish MA crossover signal."
     )
````
