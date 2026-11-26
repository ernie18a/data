# GFG MTF Candle with table by Agaam

- url: https://www.tradingview.com/script/ezzhy07c-GFG-MTF-Candle-with-table-by-Agaam/
- type: indicator
- pine_id: PUB;2796b44bdb6a4868b1a5f1ad8a641993
- version: 1.0

## Description

## GFG MTF Candle with table by Agaam

GFG MTF Candle with table by Agaam is a multi-timeframe candle-monitoring indicator that displays the active candle’s price information in a compact table while allowing the user to remain on a different chart timeframe.

The indicator can follow either the current chart candle or a selected higher-timeframe candle. It also includes optional chart markers that identify where each new selected timeframe candle begins.

### Information displayed in the table

The table shows:

* Selected candle timeframe
* Time remaining until the candle closes
* Candle opening price
* Current closing price
* Current candle high
* Current candle low
* Bull, Bear, or Doji status
* A compact visual representation of the candle body and wicks

“Wick Top” represents the candle’s current highest price.

“Wick Bottom” represents the candle’s current lowest price.

All price values use the symbol’s minimum tick formatting.

### Candle direction

The active candle is classified as:

* **Bull** when the current close is above the open
* **Bear** when the current close is below the open
* **Doji** when the current close equals the open

Bullish, bearish, and doji colors can be customized separately.

### Miniature candle display

The third table column contains a simplified text-based representation of the selected candle.

The visual uses:

* Solid blocks to represent the area between the open and close
* Vertical lines to represent the upper and lower wick areas
* The current Bull, Bear, or Doji color

This display is intended as a quick visual reference. It is an approximation and is not a full replacement for a standard candlestick.

### Timeframe modes

The indicator includes two operating modes.

#### Use Chart Timeframe

When enabled, the table follows the active candle on the current chart.

For example, when applied to a 5-minute chart, the table displays the current 5-minute candle.

#### Custom Timeframe

When “Use Chart Timeframe” is disabled, the table follows the selected custom timeframe.

For example:

* Chart timeframe: 1 minute
* Custom table timeframe: 15 minutes

The table will display the developing 15-minute candle while the user continues viewing the 1-minute chart.

The custom table timeframe should be equal to or higher than the chart timeframe.

### Candle countdown

The countdown displays the estimated time remaining before the selected candle closes.

Depending on the remaining duration, the timer is displayed as:

* Minutes and seconds
* Hours, minutes, and seconds

Examples:

* `4:32`
* `1:14:08`

When a valid candle-closing timestamp is unavailable, the countdown may display `--:--`.

Countdown availability can depend on the symbol, chart type, trading session, and data supplied by TradingView.

### Higher-timeframe candle markers

Optional markers can be displayed on the price chart whenever a new candle begins on the selected marker timeframe.

Examples include:

* `5` for a 5-minute candle
* `30` for a 30-minute candle
* `60` for a 60-minute candle
* `1D` for a daily candle
* `1W` for a weekly candle
* `1M` for a monthly candle

The marker identifies the first chart bar belonging to the new selected timeframe candle.

It does not represent a trading signal or show the opening-price value.

### Marker settings

Users can control:

* Whether markers are displayed
* Marker timeframe
* Marker position above or below the candle
* Marker text color
* Marker text size
* Distance from the candle in ticks
* Maximum number of markers retained on the chart

When the selected marker limit is exceeded, the oldest marker is removed first.

The marker timeframe should be equal to or higher than the chart timeframe.

### Table customization

The table can be customized through the indicator settings.

Available options include:

* Show or hide the table
* Use chart or custom timeframe
* Table text size
* Bull candle color
* Bear candle color
* Doji candle color
* Table background color
* Table text color
* Transparent table background

### Live candle behavior

The table monitors the currently developing candle.

While that candle remains open, the following values may continue changing:

* High
* Low
* Close
* Bull, Bear, or Doji status
* Miniature candle shape
* Remaining time

The opening price remains fixed after the candle begins.

Once the candle closes, its final OHLC values are complete, and the table begins monitoring the next active candle.

### Repainting information

The indicator does not intentionally use future-bar information or lookahead calculations.

However, the active candle is unfinished. Its high, low, close, direction, and candle appearance naturally update as new price data becomes available.

When a higher timeframe is selected, its values continue developing until that higher-timeframe candle closes.

This is normal live-candle behavior and should not be interpreted as a confirmed signal before the selected candle has closed.

### Suggested uses

The indicator may help with:

* Monitoring a higher-timeframe candle from a lower-timeframe chart
* Comparing the current price with the higher-timeframe open
* Tracking the developing candle high and low
* Observing whether the active candle is bullish, bearish, or neutral
* Monitoring time remaining before candle close
* Identifying where new higher-timeframe candles begin
* Supporting multi-timeframe price-action analysis

Example setup:

* Chart timeframe: 5 minutes
* Table timeframe: 30 minutes
* Marker timeframe: 30 minutes

This setup allows the user to view 5-minute price action while monitoring the developing 30-minute candle.

### Limitations

This indicator does not:

* Generate automatic buy or sell signals
* Predict future market direction
* Measure order flow
* Calculate bid-and-ask delta
* Determine institutional activity
* Provide stop-loss or take-profit levels
* Execute trades
* Backtest a trading strategy

The miniature candle display is a simplified representation and may not reproduce every proportional detail of a standard candlestick.

### Disclaimer

This indicator is intended for informational and educational purposes only.

It is not financial, investment, or trading advice. It does not guarantee profitable results or predict future price movements. Trading involves risk, including the potential loss of capital.

Users should perform their own analysis and apply appropriate risk-management practices before making trading decisions.

## Source Code

````pine
//@version=6
indicator("GFG MTF Candle with table by Agaam", overlay=true, max_labels_count=500)

//==================================================
// INPUTS
//==================================================

bool useChartTimeframe = input.bool(true, "Use Chart Timeframe")
string customTf = input.timeframe("5", "Custom Timeframe")
bool showTable = input.bool(true, "Show Table")

string tableSizeInput = input.string("Small", "Table Size", options=["Tiny", "Small", "Normal", "Large"])

color bullColor = input.color(color.lime, "Bull Candle Color")
color bearColor = input.color(color.red, "Bear Candle Color")
color dojiColor = input.color(color.gray, "Doji Candle Color")

color bodyBgColor = input.color(color.new(color.black, 0), "Table Body Background")
color bodyTextColor = input.color(color.white, "Table Text Color")
bool removeTableBg = input.bool(false, "Remove Table Body Background")

bool showOpenMarker = input.bool(true, "Show HTF Open Marker On Chart")
string markerTf = input.timeframe("30", "Marker Timeframe")
string markerPosition = input.string("Below Candle", "Marker Position", options=["Below Candle", "Above Candle"])
string markerSizeInput = input.string("Small", "Marker Size", options=["Tiny", "Small", "Normal", "Large"])
color markerTextColor = input.color(color.white, "Marker Text Color")

int maxMarkerLabels = input.int(30, "Max Chart Labels", minval=1, maxval=300)
int markerOffsetDownTk = input.int(10, "Marker Offset Down (Ticks)", minval=0)
int markerOffsetUpTk = input.int(10, "Marker Offset Up (Ticks)", minval=0)

//==================================================
// HELPERS
//==================================================

string tfUsed = useChartTimeframe ? timeframe.period : customTf

string tableTextSize = tableSizeInput == "Tiny" ? size.tiny : tableSizeInput == "Normal" ? size.normal : tableSizeInput == "Large" ? size.large : size.small

string markerSize = markerSizeInput == "Tiny" ? size.tiny : markerSizeInput == "Normal" ? size.normal : markerSizeInput == "Large" ? size.large : size.small

color bodyBgFinal = removeTableBg ? color.new(bodyBgColor, 100) : bodyBgColor

float downOffset = markerOffsetDownTk * syminfo.mintick
float upOffset = markerOffsetUpTk * syminfo.mintick

f_pad2(int number) =>
    number < 10 ? "0" + str.tostring(number) : str.tostring(number)

f_countdown_text(int milliseconds) =>
    string result = "--:--"

    if not na(milliseconds)
        int safeMilliseconds = math.max(milliseconds, 0)
        int totalSeconds = int(math.floor(safeMilliseconds / 1000))
        int hours = int(math.floor(totalSeconds / 3600))
        int minutes = int(math.floor((totalSeconds % 3600) / 60))
        int seconds = int(totalSeconds % 60)

        if hours > 0
            result := str.tostring(hours) + ":" + f_pad2(minutes) + ":" + f_pad2(seconds)
        else
            result := str.tostring(minutes) + ":" + f_pad2(seconds)

    result

f_candle_text(float candleOpen, float candleHigh, float candleLow, float candleClose) =>
    string result = ""

    if not na(candleOpen) and not na(candleHigh) and not na(candleLow) and not na(candleClose)
        int rows = 7

        float candleRange = math.max(candleHigh - candleLow, syminfo.mintick)

        int openRow = int(math.round((candleOpen - candleLow) / candleRange * (rows - 1)))
        int closeRow = int(math.round((candleClose - candleLow) / candleRange * (rows - 1)))

        openRow := math.max(0, math.min(rows - 1, openRow))
        closeRow := math.max(0, math.min(rows - 1, closeRow))

        int bodyTopRow = math.max(openRow, closeRow)
        int bodyBottomRow = math.min(openRow, closeRow)

        for rowIndex = 0 to rows - 1
            int displayedRow = (rows - 1) - rowIndex

            string candleCharacter = displayedRow <= bodyTopRow and displayedRow >= bodyBottomRow ? "█" : "│"

            result := result + candleCharacter

            if rowIndex < rows - 1
                result := result + "\n"

    result

f_marker_text(string selectedTimeframe) =>
    string result = selectedTimeframe

    if selectedTimeframe == "D" or selectedTimeframe == "1D"
        result := "1D"
    else if selectedTimeframe == "W" or selectedTimeframe == "1W"
        result := "1W"
    else if selectedTimeframe == "M" or selectedTimeframe == "1M"
        result := "1M"

    result

//==================================================
// TIMEFRAME VALIDATION
//==================================================

float chartTfSeconds = timeframe.in_seconds(timeframe.period)
float tableTfSeconds = timeframe.in_seconds(tfUsed)
float markerTfSeconds = timeframe.in_seconds(markerTf)

bool tableTfTooLow = showTable and not useChartTimeframe and not na(chartTfSeconds) and not na(tableTfSeconds) and tableTfSeconds < chartTfSeconds

bool markerTfTooLow = showOpenMarker and not na(chartTfSeconds) and not na(markerTfSeconds) and markerTfSeconds < chartTfSeconds

if tableTfTooLow
    runtime.error("Custom Timeframe must be equal to or higher than the chart timeframe.")

if markerTfTooLow
    runtime.error("Marker Timeframe must be equal to or higher than the chart timeframe.")

//==================================================
// GET SELECTED TIMEFRAME DATA
// One tuple request retrieves all candle values.
//==================================================

[tfOpen, tfHigh, tfLow, tfClose, tfTimeClose] = request.security(syminfo.tickerid, tfUsed, [open, high, low, close, time_close], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//==================================================
// TABLE VALUES
//==================================================

int remainingMs = na(tfTimeClose) ? na : math.max(tfTimeClose - timenow, 0)

string countdownText = f_countdown_text(remainingMs)

bool validCandle = not na(tfOpen) and not na(tfHigh) and not na(tfLow) and not na(tfClose)

bool isBull = validCandle and tfClose > tfOpen
bool isBear = validCandle and tfClose < tfOpen

color candleColor = isBull ? bullColor : isBear ? bearColor : dojiColor

string candleText = validCandle ? f_candle_text(tfOpen, tfHigh, tfLow, tfClose) : ""

string openText = na(tfOpen) ? "N/A" : str.tostring(tfOpen, format.mintick)
string closeText = na(tfClose) ? "N/A" : str.tostring(tfClose, format.mintick)
string highText = na(tfHigh) ? "N/A" : str.tostring(tfHigh, format.mintick)
string lowText = na(tfLow) ? "N/A" : str.tostring(tfLow, format.mintick)

string stateText = not validCandle ? "N/A" : isBull ? "Bull" : isBear ? "Bear" : "Doji"

//==================================================
// HTF OPEN TIMEFRAME MARKERS
//==================================================

bool newMarkerBar = timeframe.change(markerTf)

string markerText = f_marker_text(markerTf)

var array<label> markerLabels = array.new<label>()

if showOpenMarker and newMarkerBar
    float markerY = markerPosition == "Below Candle" ? low - downOffset : high + upOffset

    label newMarkerLabel = label.new(bar_index, markerY, markerText, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, textcolor=markerTextColor, size=markerSize)

    array.push(markerLabels, newMarkerLabel)

// Delete the oldest markers when the selected limit is exceeded.
while array.size(markerLabels) > maxMarkerLabels
    label oldestMarkerLabel = array.shift(markerLabels)

    if not na(oldestMarkerLabel)
        label.delete(oldestMarkerLabel)

//==================================================
// TABLE
//==================================================

var table candleTable = table.new(position.bottom_right, 3, 6, border_width=1)

if barstate.islast
    // Clearing on every last-bar execution ensures the table disappears
    // immediately when Show Table is turned off.
    table.clear(candleTable, 0, 0, 2, 5)

    if showTable
        //==================================================
        // ROW 1: TIMEFRAME AND MINI CANDLE
        //==================================================

        table.cell(candleTable, 0, 0, "Timeframe", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 1, 0, tfUsed, text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 2, 0, candleText, text_color=candleColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        //==================================================
        // ROW 2: COUNTDOWN
        //==================================================

        table.cell(candleTable, 0, 1, "Countdown", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 1, 1, countdownText, text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 2, 1, "", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        //==================================================
        // ROW 3: OPEN
        //==================================================

        table.cell(candleTable, 0, 2, "Open", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 1, 2, openText, text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 2, 2, "", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        //==================================================
        // ROW 4: CLOSE
        //==================================================

        table.cell(candleTable, 0, 3, "Close", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 1, 3, closeText, text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 2, 3, "", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        //==================================================
        // ROW 5: HIGH / TOP WICK
        //==================================================

        table.cell(candleTable, 0, 4, "Wick Top", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 1, 4, highText, text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 2, 4, "", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        //==================================================
        // ROW 6: LOW / BOTTOM WICK AND STATE
        //==================================================

        table.cell(candleTable, 0, 5, "Wick Bottom", text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 1, 5, lowText, text_color=bodyTextColor, bgcolor=bodyBgFinal, text_size=tableTextSize)

        table.cell(candleTable, 2, 5, stateText, text_color=candleColor, bgcolor=bodyBgFinal, text_size=tableTextSize)
````
