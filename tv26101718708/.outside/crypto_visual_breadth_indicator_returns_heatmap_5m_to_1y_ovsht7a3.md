# Crypto Visual Breadth Indicator % Returns Heatmap - 5m to 1Y

- url: https://www.tradingview.com/script/OvsHt7A3-Crypto-Visual-Breadth-Indicator-Returns-Heatmap-5m-to-1Y/
- type: indicator
- pine_id: PUB;869a7e448a7646929aed1324e4d15d67
- version: 1.0

## Description

Crypto % Returns Heatmap – 5m to 1Y is a multi-timeframe performance dashboard that compares the currently viewed instrument with a preset list of major non-stable cryptocurrencies.

Each row displays rolling percentage returns across 17 horizons, from 5 minutes through 1 year. Positive returns are shown in green, negative returns in red, and near-flat moves in grey.

The first row automatically follows the instrument currently open on TradingView, allowing users to flip between charts and immediately compare that instrument’s momentum profile against major crypto assets.

Users can display the Top 5, Top 10, Top 15, Top 20 or a custom number of rows, change preset symbols, resize the table text, move the dashboard around the screen, display it over the main price chart or in a lower indicator pane, and hide the table completely.

Longer horizons use approximate periods of 30, 90, 180 and 365 days. The preset crypto ordering is manually maintained because Pine Script cannot dynamically retrieve and sort external live market-cap rankings.

The indicator is designed as a visual market-comparison tool rather than a trading signal. Green and red cells describe recent price performance only and should be interpreted alongside broader market analysis and risk management.

This is a nice way to see the breath of the top 20 cryptos or which every ones you set it up to monitor, it shows visually when the market trends change simply by turning green or red. When most are the same colour then the trend is stronger

Good luck trading I hope this helps you see if you are trading with the trend and if you suddenly need to get out or cut size. TRaingle 

https://www.tradingview.com/x/NZ2X9Pd7/

## Source Code

````pine
//@version=6
indicator(
     "Crypto % Returns Heatmap - 5m to 1Y",
     shorttitle="Crypto Returns Heatmap",
     overlay=false,
     dynamic_requests=true
)

//======================================================================
// CRYPTO % RETURNS HEATMAP - 5m TO 1Y
//======================================================================
//
// DESCRIPTION
// -----------
//
// Crypto % Returns Heatmap is a multi-timeframe performance dashboard
// designed to provide a quick visual overview of market momentum across
// short-, medium- and long-term time horizons.
//
// The indicator displays the percentage price change of each selected
// instrument over:
//
// 5m
// 15m
// 30m
// 1H
// 2H
// 4H
// 8H
// 12H
// 24H
// 2D
// 3D
// 1W
// 2W
// 1M
// 3M
// 6M
// 1Y
//
// Every cell contains the actual percentage move.
//
// GREEN = positive return
// RED   = negative return
// GREY  = approximately unchanged
//
//======================================================================
// CURRENT CHART ROW
//======================================================================
//
// The first data row automatically follows the instrument currently open
// on the TradingView chart.
//
// When the user changes chart, the first row automatically recalculates
// the same return periods for the newly selected instrument.
//
//======================================================================
// PRESET CRYPTO LIST
//======================================================================
//
// Beneath the current-chart row is a preset list of major cryptocurrencies.
//
// Stablecoins are deliberately excluded.
//
// Users can display:
//
// Top 5
// Top 10
// Top 15
// Top 20
// Custom
//
// When Current Chart is ON:
//
// Top 20 means:
//
// 1 current TradingView instrument
// + 19 preset crypto rows
// = 20 displayed data rows.
//
//======================================================================
// MARKET-CAP NOTE
//======================================================================
//
// Pine Script cannot dynamically retrieve and sort live market-cap rankings
// from external websites such as CoinMarketCap or CoinGecko.
//
// The preset universe is therefore manually maintained.
//
//======================================================================
// RETURN CALCULATIONS
//======================================================================
//
// These are rolling percentage returns.
//
// Examples:
//
// 5m  = current price versus approximately 5 minutes ago
// 1H  = current price versus approximately 1 hour ago
// 24H = current price versus approximately 24 hours ago
// 1W  = current price versus approximately 7 days ago
// 1M  = current price versus approximately 30 days ago
// 1Y  = current price versus approximately 365 days ago
//
// Longer periods:
//
// 1M = 30 days
// 3M = 90 days
// 6M = 180 days
// 1Y = 365 days
//
//======================================================================
// DEFAULT DISPLAY
//======================================================================
//
// Display Location = Lower Indicator Window
// Position         = Bottom Left
// Text Size        = Normal
//
// The user can switch the table to:
//
// Main Price Chart
//
// at any time in Settings.
//
//======================================================================
// DATA DESIGN
//======================================================================
//
// Each instrument uses:
//
// 1 x 5-minute request
// 1 x daily request
//
// The different return horizons are calculated from those data streams.
//
// calc_bars_count is restricted to reduce TradingView memory usage.
//
//======================================================================
// LIMITATIONS
//======================================================================
//
// This dashboard measures PRICE PERFORMANCE only.
//
// It does not directly calculate:
//
// • Open interest
// • Funding
// • Liquidations
// • Spot volume
// • ETF flows
// • Exchange flows
// • On-chain data
// • Market capitalization
//
//======================================================================
// DISCLAIMER
//======================================================================
//
// This indicator is an analytical and visualization tool.
//
// Green is not automatically a buy signal.
// Red is not automatically a sell signal.
//
//======================================================================


//======================================================================
// CURRENT CHART
//======================================================================

showCurrentChart = input.bool(
     true,
     "Show Current Chart First",
     tooltip=
         "Displays the instrument currently open in TradingView as the first data row.",
     group="Current Chart",
     display=display.none
)


//======================================================================
// NUMBER OF DISPLAYED ROWS
//======================================================================

rowModeInput = input.string(
     "Top 20",
     "Number of Rows",
     options=[
         "Top 5",
         "Top 10",
         "Top 15",
         "Top 20",
         "Custom"
     ],
     tooltip=
         "Includes the current TradingView instrument when Current Chart is enabled.",
     group="Crypto List",
     display=display.none
)

customTotalRows = input.int(
     10,
     "Custom Total Rows",
     minval=1,
     maxval=20,
     tooltip=
         "Used only when Number of Rows is set to Custom.",
     group="Crypto List",
     display=display.none
)


//======================================================================
// TOTAL ROW COUNT
//======================================================================

getTotalRows() =>

    int result = 20

    if rowModeInput == "Top 5"
        result := 5

    else if rowModeInput == "Top 10"
        result := 10

    else if rowModeInput == "Top 15"
        result := 15

    else if rowModeInput == "Top 20"
        result := 20

    else
        result := customTotalRows

    result


totalRowsWanted =
     getTotalRows()


//======================================================================
// PRESET ROW COUNT
//======================================================================

presetRowsWanted =
     showCurrentChart ?
     math.max(
         totalRowsWanted - 1,
         0
     ) :
     math.min(
         totalRowsWanted,
         19
     )


//======================================================================
// PRESET SYMBOLS
//======================================================================

symbol1 = input.symbol(
     "CRYPTO:BTCUSD",
     "#1 BTC",
     group="Preset Symbols",
     display=display.none
)

symbol2 = input.symbol(
     "CRYPTO:ETHUSD",
     "#2 ETH",
     group="Preset Symbols",
     display=display.none
)

symbol3 = input.symbol(
     "CRYPTO:BNBUSD",
     "#3 BNB",
     group="Preset Symbols",
     display=display.none
)

symbol4 = input.symbol(
     "CRYPTO:XRPUSD",
     "#4 XRP",
     group="Preset Symbols",
     display=display.none
)

symbol5 = input.symbol(
     "CRYPTO:SOLUSD",
     "#5 SOL",
     group="Preset Symbols",
     display=display.none
)

symbol6 = input.symbol(
     "CRYPTO:TRXUSD",
     "#6 TRX",
     group="Preset Symbols",
     display=display.none
)

symbol7 = input.symbol(
     "BITFINEX:HYPEUSD",
     "#7 HYPE",
     group="Preset Symbols",
     display=display.none
)

symbol8 = input.symbol(
     "CRYPTO:ZECUSD",
     "#8 ZEC",
     group="Preset Symbols",
     display=display.none
)

symbol9 = input.symbol(
     "CRYPTO:DOGEUSD",
     "#9 DOGE",
     group="Preset Symbols",
     display=display.none
)

symbol10 = input.symbol(
     "CRYPTO:XMRUSD",
     "#10 XMR",
     group="Preset Symbols",
     display=display.none
)

symbol11 = input.symbol(
     "CRYPTO:LINKUSD",
     "#11 LINK",
     group="Preset Symbols",
     display=display.none
)

symbol12 = input.symbol(
     "CRYPTO:ADAUSD",
     "#12 ADA",
     group="Preset Symbols",
     display=display.none
)

symbol13 = input.symbol(
     "BITFINEX:LEOUSD",
     "#13 LEO",
     group="Preset Symbols",
     display=display.none
)

symbol14 = input.symbol(
     "CRYPTO:XLMUSD",
     "#14 XLM",
     group="Preset Symbols",
     display=display.none
)

symbol15 = input.symbol(
     "CRYPTO:BCHUSD",
     "#15 BCH",
     group="Preset Symbols",
     display=display.none
)

symbol16 = input.symbol(
     "CRYPTO:LTCUSD",
     "#16 LTC",
     group="Preset Symbols",
     display=display.none
)

symbol17 = input.symbol(
     "CRYPTO:UNIUSD",
     "#17 UNI",
     group="Preset Symbols",
     display=display.none
)

symbol18 = input.symbol(
     "CRYPTO:NEARUSD",
     "#18 NEAR",
     group="Preset Symbols",
     display=display.none
)

symbol19 = input.symbol(
     "CRYPTO:AVAXUSD",
     "#19 AVAX",
     group="Preset Symbols",
     display=display.none
)


//======================================================================
// DISPLAY SETTINGS
//======================================================================

showTable = input.bool(
     true,
     "Show Heatmap Table",
     tooltip=
         "Shows or completely hides the heatmap.",
     group="Display",
     display=display.none
)


//----------------------------------------------------------------------
// DEFAULT = LOWER INDICATOR WINDOW
//----------------------------------------------------------------------

displayLocationInput = input.string(
     "Lower Indicator Window",
     "Display Location",
     options=[
         "Lower Indicator Window",
         "Main Price Chart"
     ],
     tooltip=
         "Lower Indicator Window displays the table in its own indicator pane.\n\n" +
         "Main Price Chart overlays the table on the instrument chart.",
     group="Display",
     display=display.none
)


//----------------------------------------------------------------------
// DEFAULT = BOTTOM LEFT
//----------------------------------------------------------------------

tablePositionInput = input.string(
     "Bottom Left",
     "Table Position",
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
     tooltip=
         "Default position: Bottom Left.",
     group="Display",
     display=display.none
)


//----------------------------------------------------------------------
// DEFAULT = NORMAL
//----------------------------------------------------------------------

fontInput = input.string(
     "Normal",
     "Table Text Size",
     options=[
         "Tiny",
         "Small",
         "Normal",
         "Large",
         "Huge"
     ],
     tooltip=
         "Default size: Normal.",
     group="Display",
     display=display.none
)

showPercentSigns = input.bool(
     true,
     "Show % Signs",
     tooltip=
         "Turn this off to make table cells slightly narrower.",
     group="Display",
     display=display.none
)


//======================================================================
// COLOUR SETTINGS
//======================================================================

neutralThreshold = input.float(
     0.05,
     "Neutral Threshold %",
     minval=0.0,
     step=0.01,
     tooltip=
         "Moves inside +/- this percentage are displayed grey.",
     group="Colours",
     display=display.none
)


//======================================================================
// TABLE POSITION
//======================================================================

getTablePosition(string p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Bottom Right"  => position.bottom_right
        => position.bottom_left


//======================================================================
// FONT SIZE
//======================================================================

getFontSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.normal


tablePosition =
     getTablePosition(
         tablePositionInput
     )

tableFont =
     getFontSize(
         fontInput
     )

showOnMainChart =
     displayLocationInput ==
     "Main Price Chart"


//======================================================================
// COLOURS
//======================================================================

color headerColour =
     color.rgb(
         28,
         28,
         28
     )

color currentChartColour =
     color.rgb(
         30,
         70,
         115
     )

color positiveColour =
     color.rgb(
         0,
         120,
         40
     )

color negativeColour =
     color.rgb(
         150,
         20,
         35
     )

color neutralColour =
     color.rgb(
         65,
         65,
         65
     )

color textColour =
     color.white


//======================================================================
// PERCENTAGE CHANGE
//======================================================================

pctChange(
     float currentValue,
     float previousValue
 ) =>

    float result =
         na

    if not na(currentValue) and
       not na(previousValue) and
       previousValue != 0

        result :=
             (
                 currentValue /
                 previousValue -
                 1.0
             ) *
             100.0

    result


//======================================================================
// FORMAT RETURN
//======================================================================

fmtReturn(float value) =>

    string result =
         "-"

    if not na(value)

        string plus =
             value > 0 ?
             "+" :
             ""

        string suffix =
             showPercentSigns ?
             "%" :
             ""

        result :=
             plus +
             str.tostring(
                 value,
                 "#.##"
             ) +
             suffix

    result


//======================================================================
// CELL COLOUR
//======================================================================

returnColour(float value) =>

    color result =
         neutralColour

    if not na(value)

        if math.abs(value) <=
           neutralThreshold

            result :=
                 neutralColour

        else if value > 0

            result :=
                 positiveColour

        else

            result :=
                 negativeColour

    result


//======================================================================
// MULTI-TIMEFRAME RETURN DATA
//======================================================================

getReturns(string symbol) =>

    //------------------------------------------------------------------
    // 5-MINUTE DATA
    //------------------------------------------------------------------

    [
         fiveNow,
         five1,
         five3,
         five6,
         five12,
         five24,
         five48,
         five96,
         five144,
         five288,
         five576,
         five864
     ] =
         request.security(
             symbol,
             "5",
             [
                 close,
                 close[1],
                 close[3],
                 close[6],
                 close[12],
                 close[24],
                 close[48],
                 close[96],
                 close[144],
                 close[288],
                 close[576],
                 close[864]
             ],
             ignore_invalid_symbol=true,
             calc_bars_count=900
         )


    //------------------------------------------------------------------
    // DAILY DATA
    //------------------------------------------------------------------

    [
         dayNow,
         day7,
         day14,
         day30,
         day90,
         day180,
         day365
     ] =
         request.security(
             symbol,
             "D",
             [
                 close,
                 close[7],
                 close[14],
                 close[30],
                 close[90],
                 close[180],
                 close[365]
             ],
             ignore_invalid_symbol=true,
             calc_bars_count=370
         )


    //------------------------------------------------------------------
    // RETURNS
    //------------------------------------------------------------------

    float r5m =
         pctChange(
             fiveNow,
             five1
         )

    float r15m =
         pctChange(
             fiveNow,
             five3
         )

    float r30m =
         pctChange(
             fiveNow,
             five6
         )

    float r1h =
         pctChange(
             fiveNow,
             five12
         )

    float r2h =
         pctChange(
             fiveNow,
             five24
         )

    float r4h =
         pctChange(
             fiveNow,
             five48
         )

    float r8h =
         pctChange(
             fiveNow,
             five96
         )

    float r12h =
         pctChange(
             fiveNow,
             five144
         )

    float r24h =
         pctChange(
             fiveNow,
             five288
         )

    float r2d =
         pctChange(
             fiveNow,
             five576
         )

    float r3d =
         pctChange(
             fiveNow,
             five864
         )

    float r1w =
         pctChange(
             dayNow,
             day7
         )

    float r2w =
         pctChange(
             dayNow,
             day14
         )

    float r1m =
         pctChange(
             dayNow,
             day30
         )

    float r3m =
         pctChange(
             dayNow,
             day90
         )

    float r6m =
         pctChange(
             dayNow,
             day180
         )

    float r1y =
         pctChange(
             dayNow,
             day365
         )


    [
         r5m,
         r15m,
         r30m,
         r1h,
         r2h,
         r4h,
         r8h,
         r12h,
         r24h,
         r2d,
         r3d,
         r1w,
         r2w,
         r1m,
         r3m,
         r6m,
         r1y
     ]


//======================================================================
// PRESET SYMBOL ARRAY
//======================================================================

array<string> selectedSymbols =
     array.from(
         symbol1,
         symbol2,
         symbol3,
         symbol4,
         symbol5,
         symbol6,
         symbol7,
         symbol8,
         symbol9,
         symbol10,
         symbol11,
         symbol12,
         symbol13,
         symbol14,
         symbol15,
         symbol16,
         symbol17,
         symbol18,
         symbol19
     )


//======================================================================
// DISPLAY NAMES
//======================================================================

array<string> displayNames =
     array.from(
         "1 BTC",
         "2 ETH",
         "3 BNB",
         "4 XRP",
         "5 SOL",
         "6 TRX",
         "7 HYPE",
         "8 ZEC",
         "9 DOGE",
         "10 XMR",
         "11 LINK",
         "12 ADA",
         "13 LEO",
         "14 XLM",
         "15 BCH",
         "16 LTC",
         "17 UNI",
         "18 NEAR",
         "19 AVAX"
     )


//======================================================================
// TABLE DIMENSIONS
//======================================================================

TABLE_COLUMNS =
     18

TABLE_ROWS =
     21


//======================================================================
// CREATE TABLES
//======================================================================
//
// paneTable:
// Displays inside lower indicator pane.
//
// chartTable:
// Uses force_overlay=true to display over main price chart.
//
//======================================================================

var table paneTable =
     table.new(
         tablePosition,
         TABLE_COLUMNS,
         TABLE_ROWS,
         border_width=1,
         force_overlay=false
     )

var table chartTable =
     table.new(
         tablePosition,
         TABLE_COLUMNS,
         TABLE_ROWS,
         border_width=1,
         force_overlay=true
     )


//======================================================================
// DRAW RETURN CELL
//======================================================================

drawReturnCell(
     table tableId,
     int row,
     int column,
     float value
 ) =>

    table.cell(
         tableId,
         column,
         row,
         fmtReturn(value),
         bgcolor=returnColour(value),
         text_color=textColour,
         text_size=tableFont,
         text_halign=text.align_center
     )


//======================================================================
// DRAW DATA ROW
//======================================================================

drawDataRow(
     table tableId,
     int row,
     string symbolName,
     color symbolBackground,
     float r5m,
     float r15m,
     float r30m,
     float r1h,
     float r2h,
     float r4h,
     float r8h,
     float r12h,
     float r24h,
     float r2d,
     float r3d,
     float r1w,
     float r2w,
     float r1m,
     float r3m,
     float r6m,
     float r1y
 ) =>

    table.cell(
         tableId,
         0,
         row,
         symbolName,
         bgcolor=symbolBackground,
         text_color=textColour,
         text_size=tableFont,
         text_halign=text.align_center
     )

    drawReturnCell(tableId, row, 1, r5m)
    drawReturnCell(tableId, row, 2, r15m)
    drawReturnCell(tableId, row, 3, r30m)

    drawReturnCell(tableId, row, 4, r1h)
    drawReturnCell(tableId, row, 5, r2h)
    drawReturnCell(tableId, row, 6, r4h)
    drawReturnCell(tableId, row, 7, r8h)
    drawReturnCell(tableId, row, 8, r12h)

    drawReturnCell(tableId, row, 9, r24h)

    drawReturnCell(tableId, row, 10, r2d)
    drawReturnCell(tableId, row, 11, r3d)

    drawReturnCell(tableId, row, 12, r1w)
    drawReturnCell(tableId, row, 13, r2w)

    drawReturnCell(tableId, row, 14, r1m)
    drawReturnCell(tableId, row, 15, r3m)
    drawReturnCell(tableId, row, 16, r6m)

    drawReturnCell(tableId, row, 17, r1y)


//======================================================================
// DRAW HEADINGS
//======================================================================

drawHeadings(table tableId) =>

    table.cell(
         tableId,
         0,
         0,
         "Symbol",
         bgcolor=headerColour,
         text_color=textColour,
         text_size=tableFont,
         text_halign=text.align_center
     )

    table.cell(tableId, 1, 0, "5m",  bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 2, 0, "15m", bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 3, 0, "30m", bgcolor=headerColour, text_color=textColour, text_size=tableFont)

    table.cell(tableId, 4, 0, "1H",  bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 5, 0, "2H",  bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 6, 0, "4H",  bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 7, 0, "8H",  bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 8, 0, "12H", bgcolor=headerColour, text_color=textColour, text_size=tableFont)

    table.cell(tableId, 9, 0, "24H", bgcolor=headerColour, text_color=textColour, text_size=tableFont)

    table.cell(tableId, 10, 0, "2D", bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 11, 0, "3D", bgcolor=headerColour, text_color=textColour, text_size=tableFont)

    table.cell(tableId, 12, 0, "1W", bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 13, 0, "2W", bgcolor=headerColour, text_color=textColour, text_size=tableFont)

    table.cell(tableId, 14, 0, "1M", bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 15, 0, "3M", bgcolor=headerColour, text_color=textColour, text_size=tableFont)
    table.cell(tableId, 16, 0, "6M", bgcolor=headerColour, text_color=textColour, text_size=tableFont)

    table.cell(tableId, 17, 0, "1Y", bgcolor=headerColour, text_color=textColour, text_size=tableFont)


//======================================================================
// CLEAR BOTH TABLES
//======================================================================

if barstate.islast

    table.clear(
         paneTable,
         0,
         0,
         TABLE_COLUMNS - 1,
         TABLE_ROWS - 1
     )

    table.clear(
         chartTable,
         0,
         0,
         TABLE_COLUMNS - 1,
         TABLE_ROWS - 1
     )


//======================================================================
// DRAW HEADINGS
//======================================================================

if barstate.islast and
   showTable

    table activeTable =
         showOnMainChart ?
         chartTable :
         paneTable

    drawHeadings(
         activeTable
     )


//======================================================================
// ROW COUNTER
//======================================================================

int displayRow =
     1


//======================================================================
// CURRENT TRADINGVIEW INSTRUMENT
//======================================================================

if showCurrentChart

    [
         chart5m,
         chart15m,
         chart30m,
         chart1h,
         chart2h,
         chart4h,
         chart8h,
         chart12h,
         chart24h,
         chart2d,
         chart3d,
         chart1w,
         chart2w,
         chart1m,
         chart3m,
         chart6m,
         chart1y
     ] =
         getReturns(
             syminfo.tickerid
         )


    if barstate.islast and
       showTable

        table activeTable =
             showOnMainChart ?
             chartTable :
             paneTable

        drawDataRow(
             activeTable,
             displayRow,
             "VIEW: " + syminfo.ticker,
             currentChartColour,
             chart5m,
             chart15m,
             chart30m,
             chart1h,
             chart2h,
             chart4h,
             chart8h,
             chart12h,
             chart24h,
             chart2d,
             chart3d,
             chart1w,
             chart2w,
             chart1m,
             chart3m,
             chart6m,
             chart1y
         )


    displayRow +=
         1


//======================================================================
// PRESET CRYPTO ROWS
//======================================================================

for slot = 0 to 18

    bool shouldShow =
         slot <
         presetRowsWanted


    if shouldShow

        string selectedSymbol =
             array.get(
                 selectedSymbols,
                 slot
             )

        string displayName =
             array.get(
                 displayNames,
                 slot
             )


        [
             r5m,
             r15m,
             r30m,
             r1h,
             r2h,
             r4h,
             r8h,
             r12h,
             r24h,
             r2d,
             r3d,
             r1w,
             r2w,
             r1m,
             r3m,
             r6m,
             r1y
         ] =
             getReturns(
                 selectedSymbol
             )


        if barstate.islast and
           showTable

            table activeTable =
                 showOnMainChart ?
                 chartTable :
                 paneTable

            drawDataRow(
                 activeTable,
                 displayRow,
                 displayName,
                 headerColour,
                 r5m,
                 r15m,
                 r30m,
                 r1h,
                 r2h,
                 r4h,
                 r8h,
                 r12h,
                 r24h,
                 r2d,
                 r3d,
                 r1w,
                 r2w,
                 r1m,
                 r3m,
                 r6m,
                 r1y
             )


        displayRow +=
             1
````
