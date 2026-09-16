<!-- tradingview-pine-id: PUB;1c3db0c19a334cd6812c19207ac69304 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# New Highs/Lows Market Breadth

Source: https://www.tradingview.com/script/aeLgOovL-New-Highs-Lows-Market-Breadth/

## Description

New Highs/Lows Market Breadth

This indicator is intended as a daily market breadth and participation tool. It is most useful for confirming the internal strength or weakness behind U.S. equity market price trends, monitoring changes in breadth momentum, and identifying periods when participation is expanding or contracting.

New Highs/Lows Market Breadth measures the difference between the number of securities making new highs and new lows across several major U.S. indices and exchanges.

The core calculation is:

Net Breadth = New Highs − New Lows

Positive readings indicate that new highs are outnumbering new lows, while negative readings indicate that new lows are dominating. This provides a view of participation beneath the surface of the market and can help identify strengthening or deteriorating internal conditions that may not be obvious from price alone.

Market Universes

The indicator supports multiple breadth universes from a single dropdown:

Indices

[*]Nasdaq Composite
[*]Nasdaq 100
[*]S&P 500

Exchanges

[*]NYSE
[*]AMEX
[*]Nasdaq
[*]NYSE + AMEX + Nasdaq combined

The combined exchange option sums the new-high and new-low counts from all three exchanges before calculating Net Breadth, providing a broader measure of U.S. exchange-level participation.

Lookback Periods

Breadth can be evaluated using:

[*]1 Month
[*]3 Months
[*]6 Months
[*]52 Weeks

These selections refer to the lookback used to define a new high or new low, not the chart timeframe. For example, the 1 Month setting measures securities making new one-month highs and lows during the applicable trading session.

Shorter lookbacks generally respond more quickly to changes in participation, while longer lookbacks provide a broader view of intermediate- and long-term market strength or weakness.

Breadth Display

By default, the indicator plots Net New Highs/Lows as a column histogram around the zero line.

The entire Highs/Lows histogram can be disabled independently. This allows the indicator pane to display only the moving average, background condition, or other enabled components.
[image]https://www.tradingview.com/x/SZl8QI3R/[/image]
An optional Display Highs and Lows Separately setting replaces the net histogram with separate positive columns for new highs and negative columns for new lows. This makes it easier to see whether changes in Net Breadth are being driven by expanding highs, expanding lows, or both.

Moving Average

An optional moving average can be applied directly to Net New Highs/Lows to smooth short-term fluctuations and make changes in breadth direction easier to identify.

Available moving average types include:

[*]SMA
[*]EMA
[*]WMA
[*]RMA

Length, line width, and color are customizable.

The moving average can also be colored according to its slope:

[*]Rising MA = user-defined rising color
[*]Falling MA = user-defined falling color
[*]Flat MA = default MA color

Slope coloring focuses on whether breadth momentum is improving or deteriorating rather than simply whether breadth is above or below zero.

For example, Net Breadth can remain negative while its moving average begins rising. This indicates that internal conditions are improving even though new lows may still exceed new highs. Conversely, a falling moving average above zero can indicate weakening participation before Net Breadth becomes negative.

Background Breadth Streaks

An optional background highlight identifies sustained periods of positive or negative Net Breadth.

The number of consecutive bars required to activate the background is user-defined, with 3 bars as the default.

Once the selected threshold is reached:

[*]Consecutive positive Net Breadth bars activate the positive background color.
[*]Consecutive negative Net Breadth bars activate the negative background color.
[*]The background remains active while the qualifying streak continues.

This feature is designed to distinguish persistent breadth conditions from isolated positive or negative readings.

Highs/Lows Table

An optional table displays the current number of securities making Highs and Lows for the selected market universe and lookback period.

This provides the underlying counts behind the Net Breadth calculation without requiring the Highs/Lows histogram to remain visible.

Confirmed Bars and Repainting

Repaint is disabled by default.

With Repaint disabled, the indicator displays only confirmed chart bars. This applies to the breadth plots, moving average, background conditions, and table updates.

Enabling Repaint allows the current unconfirmed chart bar to update as incoming data changes. Values displayed on an open bar can therefore change until that bar is confirmed.

Usage and Limitations

[*]Use a standard 1-day chart for the intended calculation. The underlying TradingView New High/New Low market-statistics series used by this indicator are daily-session breadth data. The indicator requests those series using the chart's current timeframe, so 1D is the recommended and intended chart timeframe.
[*]Intraday timeframes are not recommended. The source breadth series are based on daily market statistics rather than true intraday New High/New Low counts. Depending on the selected source and data availability, intraday charts may show unavailable, repeated, incomplete, or otherwise misleading values.
[*]Weekly and monthly charts change the meaning of the display. Because the script requests the breadth source at the chart timeframe, using a weekly or monthly chart does not produce the same bar-by-bar series as a daily chart. Moving-average length and consecutive-background settings will also operate on weekly or monthly bars rather than trading days. Use 1D when you want the indicator to behave as designed.
[*]Use a time-based chart rather than synthetic/non-time-based chart types. Standard candles, bars, or lines on a daily timeframe provide the clearest alignment with the daily breadth source data. Renko, Range, Kagi, Point & Figure, and similar synthetic chart types can distort the relationship between chart bars and daily breadth observations.
[*]Repaint should normally remain disabled for confirmed analysis. Enabling it allows the current unconfirmed chart bar to change before closing. Historical bars remain confirmed, but the most recent open bar should not be treated as final.
[*]Data availability is dependent on TradingView's underlying market-statistics symbols. Historical coverage may vary by index, exchange, and breadth lookback, and missing source data cannot be reconstructed by the indicator.

Credit: This indicator is based on the open-source Net New Highs/Lows script by Fred6724, with substantial modifications and additional functionality.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
//
// © cmacktrades (with open-source code from Fred6724)

//@version=6
indicator(title = "New Highs/Lows Market Breadth", shorttitle = "New Highs/Lows", overlay = false)


// ============================================================================
// INPUTS
// ============================================================================


// ----------------------------------------------------------------------------
// DATA
// ----------------------------------------------------------------------------

i_market = input.string(
     "Nasdaq Composite",
     title = "Index / Exchange",
     options = [
         "Nasdaq Composite",
         "Nasdaq 100",
         "S&P 500",
         "NYSE",
         "AMEX",
         "Nasdaq",
         "NYSE + AMEX + Nasdaq"
     ],
     group = "DATA",
     tooltip = "Select the market breadth universe. The final option combines NYSE, AMEX, and Nasdaq exchange breadth by summing their highs and lows."
)

i_period = input.string(
     "1 MONTH",
     title = "Period",
     options = [
         "1 MONTH",
         "3 MONTHS",
         "6 MONTHS",
         "52 WEEKS"
     ],
     group = "DATA"
)

i_repaint = input.bool(
     false,
     title = "Repaint",
     group = "DATA",
     tooltip = "When enabled, the indicator displays the current unconfirmed chart bar and updates it in real time. Values on that bar can change until the bar closes. When disabled (default), plots, background colors, the moving average, and table updates only use confirmed bars."
)


// ----------------------------------------------------------------------------
// DISPLAY
// ----------------------------------------------------------------------------

i_showHighsLows = input.bool(
     true,
     title = "Display Highs/Lows",
     group = "DISPLAY",
     tooltip = "Controls the display of the breadth columns. When disabled, the Highs/Lows columns are hidden while the Moving Average, Background, and Table remain independently controllable."
)

i_plotBoth = input.bool(
     false,
     title = "Display Highs and Lows Separately",
     group = "DISPLAY",
     active = i_showHighsLows
)

i_upColor = input.color(
     color.green,
     title = "Positive",
     inline = "Column Colors",
     group = "DISPLAY",
     active = i_showHighsLows
)

i_dnColor = input.color(
     color.red,
     title = "Negative",
     inline = "Column Colors",
     group = "DISPLAY",
     active = i_showHighsLows
)


// ----------------------------------------------------------------------------
// MOVING AVERAGE
// ----------------------------------------------------------------------------

i_showMA = input.bool(
     false,
     title = "Display Moving Average",
     group = "MOVING AVERAGE"
)

i_maType = input.string(
     "SMA",
     title = "Type",
     options = [
         "SMA",
         "EMA",
         "WMA",
         "RMA"
     ],
     group = "MOVING AVERAGE",
     active = i_showMA
)

i_maLength = input.int(
     10,
     title = "Length",
     minval = 1,
     inline = "MA Settings",
     group = "MOVING AVERAGE",
     active = i_showMA
)

i_maWidth = input.int(
     1,
     title = "Width",
     minval = 1,
     maxval = 5,
     inline = "MA Settings",
     group = "MOVING AVERAGE",
     active = i_showMA
)

i_maColor = input.color(
     color.white,
     title = "Default Color",
     group = "MOVING AVERAGE",
     active = i_showMA
)

i_maColorBySlope = input.bool(
     false,
     title = "Color MA by Slope",
     tooltip = "When enabled, the moving average uses separate user-defined colors when the MA is rising or falling. The default color is used when the MA is unchanged from the previous bar.",
     group = "MOVING AVERAGE",
     active = i_showMA
)

i_maSlopeUpColor = input.color(
     color.green,
     title = "Slope Up",
     inline = "MA Slope Colors",
     group = "MOVING AVERAGE",
     active = i_showMA and i_maColorBySlope
)

i_maSlopeDownColor = input.color(
     color.red,
     title = "Slope Down",
     inline = "MA Slope Colors",
     group = "MOVING AVERAGE",
     active = i_showMA and i_maColorBySlope
)


// ----------------------------------------------------------------------------
// BACKGROUND
// ----------------------------------------------------------------------------

i_Background = input.bool(
     false,
     title = "Display Background Color",
     tooltip = "Colors the background after the selected number of consecutive positive or negative net breadth bars.",
     group = "BACKGROUND"
)

i_backgroundBars = input.int(
     3,
     title = "Bars in a Row",
     minval = 1,
     maxval = 100,
     group = "BACKGROUND",
     active = i_Background,
     tooltip = "Sets the number of consecutive positive or negative net breadth bars required before the background is colored. Once the threshold is reached, the background remains colored while the streak continues."
)

i_posBackgroundColor = input.color(
     color.rgb(76, 175, 80, 70),
     title = "Positive",
     inline = "Background Colors",
     group = "BACKGROUND",
     active = i_Background
)

i_negBackgroundColor = input.color(
     color.rgb(255, 82, 82, 70),
     title = "Negative",
     inline = "Background Colors",
     group = "BACKGROUND",
     active = i_Background
)


// ----------------------------------------------------------------------------
// TABLE
// ----------------------------------------------------------------------------

i_plotTable = input.bool(
     false,
     title = "Display Number of Highs/Lows",
     group = "TABLE"
)

i_tableSize = input.string(
     "Normal",
     title = "Size",
     options = [
         "Tiny",
         "Small",
         "Normal",
         "Large"
     ],
     inline = "Table Layout",
     group = "TABLE",
     active = i_plotTable
)

i_posTable = input.string(
     "Bottom Left",
     title = "Position",
     options = [
         "Top Left",
         "Top Right",
         "Middle Left",
         "Middle Right",
         "Bottom Left",
         "Bottom Right"
     ],
     inline = "Table Layout",
     group = "TABLE",
     active = i_plotTable
)

i_tableAlignment = input.string(
     "Center",
     title = "Text Alignment",
     options = [
         "Left",
         "Center",
         "Right"
     ],
     group = "TABLE",
     active = i_plotTable
)


// Table Cell Colors

i_tableLabelBgColor = input.color(
     color.rgb(209, 212, 219, 0),
     title = "Label Background",
     inline = "Table Backgrounds",
     group = "TABLE",
     active = i_plotTable
)

i_tableValueBgColor = input.color(
     color.rgb(209, 212, 219, 0),
     title = "Value Background",
     inline = "Table Backgrounds",
     group = "TABLE",
     active = i_plotTable
)


// Table Text Colors

i_tableLabelTextColor = input.color(
     color.rgb(54, 58, 69, 0),
     title = "Labels",
     inline = "Table Text",
     group = "TABLE",
     active = i_plotTable
)

i_tableHighTextColor = input.color(
     color.green,
     title = "Highs",
     inline = "Table Text",
     group = "TABLE",
     active = i_plotTable
)

i_tableLowTextColor = input.color(
     color.red,
     title = "Lows",
     inline = "Table Text",
     group = "TABLE",
     active = i_plotTable
)


// Table Borders

i_tableBorderColor = input.color(
     color.rgb(209, 212, 219, 0),
     title = "Border",
     inline = "Table Border",
     group = "TABLE",
     active = i_plotTable
)

i_tableBorderWidth = input.int(
     1,
     title = "Width",
     minval = 0,
     maxval = 5,
     inline = "Table Border",
     group = "TABLE",
     active = i_plotTable
)


// Table Outer Frame

i_tableFrameColor = input.color(
     color.rgb(209, 212, 219, 0),
     title = "Frame",
     inline = "Table Frame",
     group = "TABLE",
     active = i_plotTable
)

i_tableFrameWidth = input.int(
     0,
     title = "Width",
     minval = 0,
     maxval = 5,
     inline = "Table Frame",
     group = "TABLE",
     active = i_plotTable
)


// ============================================================================
// MARKET BREADTH SYMBOL SELECTION
// ============================================================================
//
// INDEX SERIES
//
// Nasdaq Composite:
//     1 Month  = N1HO / N1LO
//     3 Months = N3HO / N3LO
//     6 Months = N6HO / N6LO
//     52 Weeks = NAHO / NALO
//
// Nasdaq 100:
//     1 Month  = N1HC / N1LC
//     3 Months = N3HC / N3LC
//     6 Months = N6HC / N6LC
//     52 Weeks = NAHC / NALC
//
// S&P 500:
//     1 Month  = M1HP / M1LP
//     3 Months = M3HP / M3LP
//     6 Months = M6HP / M6LP
//     52 Weeks = MAHP / MALP
//
//
// EXCHANGE SERIES
//
// NYSE:
//     1 Month  = M1HN / M1LN
//     3 Months = M3HN / M3LN
//     6 Months = M6HN / M6LN
//     52 Weeks = MAHN / MALN
//
// AMEX:
//     1 Month  = M1HA / M1LA
//     3 Months = M3HA / M3LA
//     6 Months = M6HA / M6LA
//     52 Weeks = MAHA / MALA
//
// Nasdaq:
//     1 Month  = M1HQ / M1LQ
//     3 Months = M3HQ / M3LQ
//     6 Months = M6HQ / M6LQ
//     52 Weeks = MAHQ / MALQ
//
// Combined:
//     NYSE + AMEX + Nasdaq sums the three exchange series.
// ============================================================================


// Is the combined exchange breadth option selected?
bool combinedExchanges =
     i_market == "NYSE + AMEX + Nasdaq"


// Determine period prefix for broad exchange and S&P families.
string exchangePeriodCode = switch i_period
    "1 MONTH"  => "M1"
    "3 MONTHS" => "M3"
    "6 MONTHS" => "M6"
    "52 WEEKS" => "MA"


// Determine period prefix for Nasdaq Composite / Nasdaq 100.
string nasdaqIndexPeriodCode = switch i_period
    "1 MONTH"  => "N1"
    "3 MONTHS" => "N3"
    "6 MONTHS" => "N6"
    "52 WEEKS" => "NA"


// Determine which period family applies to selected market.
string selectedPeriodCode =
     i_market == "Nasdaq Composite" or i_market == "Nasdaq 100"
         ? nasdaqIndexPeriodCode
         : exchangePeriodCode


// Determine suffix for individually selected markets.
string marketCode = switch i_market
    "Nasdaq Composite" => "O"
    "Nasdaq 100"       => "C"
    "S&P 500"          => "P"
    "NYSE"             => "N"
    "AMEX"             => "A"
    "Nasdaq"           => "Q"
    => "N"


// Symbols used when a single index/exchange is selected.
string selectedHighSymbol =
     "INDEX:" + selectedPeriodCode + "H" + marketCode

string selectedLowSymbol =
     "INDEX:" + selectedPeriodCode + "L" + marketCode


// Symbols used for combined exchange option.
string nyseHighSymbol =
     "INDEX:" + exchangePeriodCode + "HN"

string nyseLowSymbol =
     "INDEX:" + exchangePeriodCode + "LN"

string amexHighSymbol =
     "INDEX:" + exchangePeriodCode + "HA"

string amexLowSymbol =
     "INDEX:" + exchangePeriodCode + "LA"

string nasdaqHighSymbol =
     "INDEX:" + exchangePeriodCode + "HQ"

string nasdaqLowSymbol =
     "INDEX:" + exchangePeriodCode + "LQ"


// ============================================================================
// REQUEST MARKET BREADTH DATA
// ============================================================================

float highs = na
float rawLows = na


// Combined NYSE + AMEX + Nasdaq exchange breadth
if combinedExchanges

    float nyseHighs = request.security(
         nyseHighSymbol,
         timeframe.period,
         close
    )

    float nyseLows = request.security(
         nyseLowSymbol,
         timeframe.period,
         close
    )

    float amexHighs = request.security(
         amexHighSymbol,
         timeframe.period,
         close
    )

    float amexLows = request.security(
         amexLowSymbol,
         timeframe.period,
         close
    )

    float nasdaqHighs = request.security(
         nasdaqHighSymbol,
         timeframe.period,
         close
    )

    float nasdaqLows = request.security(
         nasdaqLowSymbol,
         timeframe.period,
         close
    )

    highs :=
         nyseHighs +
         amexHighs +
         nasdaqHighs

    rawLows :=
         nyseLows +
         amexLows +
         nasdaqLows


// Single index/exchange breadth
else

    highs := request.security(
         selectedHighSymbol,
         timeframe.period,
         close
    )

    rawLows := request.security(
         selectedLowSymbol,
         timeframe.period,
         close
    )


// Convert lows to negative values when displayed separately.
float lows =
     -rawLows


// ============================================================================
// CALCULATIONS
// ============================================================================

// Net New Highs - New Lows
float highAndLows =
     highs - rawLows


// True on all historical bars and on the closing update of a realtime bar.
// Enabling Repaint allows the current unconfirmed realtime bar to display.
bool showBar =
     i_repaint or barstate.isconfirmed


// ============================================================================
// BACKGROUND COLOR
// ============================================================================


// Returns true when the required number of consecutive bars are all
// positive or all negative.
f_consecutiveBreadth(
     float source,
     int barsRequired,
     bool positiveDirection
 ) =>
    bool condition = true

    for i = 0 to barsRequired - 1
        condition :=
             condition and
             (positiveDirection ? source[i] > 0 : source[i] < 0)

    condition


bool condGreen =
     f_consecutiveBreadth(
         highAndLows,
         i_backgroundBars,
         true
     )

bool condRed =
     f_consecutiveBreadth(
         highAndLows,
         i_backgroundBars,
         false
     )


color backgroundColor =
     condGreen ? i_posBackgroundColor :
     condRed   ? i_negBackgroundColor :
     na


bgcolor(
     showBar and i_Background
         ? backgroundColor
         : na
)


// ============================================================================
// COLUMN COLORS
// ============================================================================

color myColor =
     highAndLows > 0
         ? i_upColor
         : i_dnColor


// ============================================================================
// MAIN OUTPUT
// ============================================================================


// Net New Highs - New Lows
plot(
     i_showHighsLows and
     not i_plotBoth and
     showBar
         ? highAndLows
         : na,
     title = "New Highs - New Lows",
     color = myColor,
     style = plot.style_columns,
     linewidth = 2
)


// Highs displayed separately
plot(
     i_showHighsLows and
     i_plotBoth and
     showBar
         ? highs
         : na,
     title = "New Highs",
     color = i_upColor,
     style = plot.style_columns,
     linewidth = 2
)


// Lows displayed separately
plot(
     i_showHighsLows and
     i_plotBoth and
     showBar
         ? lows
         : na,
     title = "New Lows",
     color = i_dnColor,
     style = plot.style_columns,
     linewidth = 2
)


// ============================================================================
// MOVING AVERAGE
// ============================================================================

f_ma(
     float source,
     int length,
     string maType
 ) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "WMA" => ta.wma(source, length)
        "RMA" => ta.rma(source, length)
        => ta.sma(source, length)


float maValue =
     f_ma(
         highAndLows,
         i_maLength,
         i_maType
     )


// MA slope:
// Rising  = current MA > previous MA
// Falling = current MA < previous MA
// Flat    = current MA == previous MA

bool maSlopeUp =
     maValue > maValue[1]

bool maSlopeDown =
     maValue < maValue[1]


color maPlotColor =
     i_maColorBySlope
         ? maSlopeUp
             ? i_maSlopeUpColor
             : maSlopeDown
                 ? i_maSlopeDownColor
                 : i_maColor
         : i_maColor


plot(
     i_showMA and showBar
         ? maValue
         : na,
     title = "Moving Average",
     color = maPlotColor,
     linewidth = i_maWidth
)


// ============================================================================
// TABLE SETTINGS
// ============================================================================

tableSize = switch i_tableSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    "Large"  => size.large


posTable = switch i_posTable
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Middle Left"  => position.middle_left
    "Middle Right" => position.middle_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right


tableTextAlign = switch i_tableAlignment
    "Left"   => text.align_left
    "Center" => text.align_center
    "Right"  => text.align_right


// ============================================================================
// TABLE
// ============================================================================

var table newHighLowTable = table.new(
     posTable,
     2,
     2,
     frame_color = i_tableFrameColor,
     frame_width = i_tableFrameWidth,
     border_color = i_tableBorderColor,
     border_width = i_tableBorderWidth
)


// ============================================================================
// TABLE CELL FUNCTIONS
// ============================================================================


// Label cell
f_fillLabelCell(
     _table,
     _column,
     _row,
     _text
 ) =>

    table.cell(
         _table,
         _column,
         _row,
         text = _text,
         bgcolor = i_tableLabelBgColor,
         text_color = i_tableLabelTextColor,
         text_size = tableSize,
         text_halign = tableTextAlign
    )


// Value cell
f_fillValueCell(
     _table,
     _column,
     _row,
     _value,
     _textColor
 ) =>

    string _cellText =
         str.tostring(_value, "0")

    table.cell(
         _table,
         _column,
         _row,
         text = _cellText,
         bgcolor = i_tableValueBgColor,
         text_color = _textColor,
         text_size = tableSize,
         text_halign = tableTextAlign
    )


// ============================================================================
// DISPLAY TABLE
// ============================================================================
//
// When Repaint is disabled, the table keeps the most recent confirmed values
// until the current chart bar closes.
// ============================================================================

if i_plotTable and showBar

    // Labels
    f_fillLabelCell(
         newHighLowTable,
         0,
         0,
         "Highs"
    )

    f_fillLabelCell(
         newHighLowTable,
         0,
         1,
         "Lows"
    )

    // Values
    f_fillValueCell(
         newHighLowTable,
         1,
         0,
         highs,
         i_tableHighTextColor
    )

    f_fillValueCell(
         newHighLowTable,
         1,
         1,
         rawLows,
         i_tableLowTextColor
    )
````
