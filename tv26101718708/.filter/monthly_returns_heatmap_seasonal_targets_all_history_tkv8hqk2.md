# Monthly Returns Heatmap & Seasonal Targets [All History]

- url: https://www.tradingview.com/script/tKv8HqK2-Monthly-Returns-Heatmap-Seasonal-Targets-All-History/
- type: indicator
- pine_id: PUB;a48e4f6f9c4645fe86346f7c5e31bd91
- version: 1.0

## Description

Monthly Returns Heatmap & Seasonal Targets [All History] displays historical monthly percentage gains and losses for the instrument currently on the chart. The year-by-month heatmap uses green for positive returns and red for negative returns, while the historical-average row provides a monthly seasonal reference.

In addition to the traditional monthly returns heatmap, the indicator includes a current-month Seasonal Target Table showing historical average and median returns, positive-year frequency, current-month performance, a historical seasonal target price, the percentage move remaining from the current price to that reference, and the number of historical observations used.

Monthly return heatmaps and seasonality analysis are established market-analysis techniques. This indicator brings these elements together with the additional current-month target-reference calculations in one configurable display. Historical seasonal values are descriptive reference calculations, not forecasts or guarantees.

I am using this as a factor to see where strength and weakness exists to look for triangle breakout direction to achieve a higher net success in trading triangles. This is one of a number of tools in my toolbox that allows me to hit my stretch targets in triangle trading to maintain or even hopefully improve upon prior years performance and remain in the top 1% of world traders, you need to be right in your knowledge of the direction of the God markets first before you can decide which way the triangle will breakout. This script and many others (as of yet unpublished) help form a part of that. 

I wish you all luck and happy successful trading out there, reach out if you have any questions, please reach out and follow me and press the like button, to stay up to date and let me know about any triangles you may have found - I have lists of thousands of them multiple watch lists. Please communicate any knowledge regarding triangles to me. Manifest the life you want for yourself, break out of your old patterns, these tools help you do that by providing a quick over view of the instrument in your top down analysis before deciding to trade, stack the odds in your favour and be data driven.  I hope this helps you reduce less time trading and more time with your families and hobbies whilst banking more green! 

https://www.tradingview.com/x/uIxGgd9X/

## Source Code

````pine
//@version=6
indicator(
     "Monthly Returns Heatmap & Seasonal Targets [All History]",
     shorttitle="Monthly Returns Heatmap",
     overlay=true,
     scale=scale.none,
     behind_chart=false
)

//======================================================================
// MONTHLY RETURNS HEATMAP & SEASONAL TARGETS [ALL HISTORY]
//======================================================================
//
// Author: William Playfair
//
// WHAT THIS INDICATOR DOES
// ------------------------
// Displays historical monthly percentage returns for the instrument
// currently open on the TradingView chart.
//
// It combines:
//
// 1. A year-by-month monthly returns heatmap.
// 2. A current-month Seasonal Target Table.
//
// GREEN = positive monthly return.
// RED   = negative monthly return.
// BLUE  = historical seasonal reference.
//
// Historical seasonal targets are reference calculations, not forecasts.
//
//======================================================================


//======================================================================
// CONSTANT
//======================================================================

MAX_DISPLAY_YEARS = 150


//======================================================================
// DISPLAY / PRINT SETTINGS
//======================================================================

presentationMode = input.bool(
     false,
     "Presentation / Print Mode",
     tooltip=
         "Uses a lighter colour scheme suitable for screenshots or printing.",
     group="Display & Print",
     display=display.none
)

hideTargetInPresentation = input.bool(
     true,
     "Hide Target Table In Print Mode",
     tooltip=
         "Hides the Seasonal Target Table while Presentation Mode is active.",
     group="Display & Print",
     display=display.none
)

hideNotesInPresentation = input.bool(
     true,
     "Hide Notes Summary In Print Mode",
     tooltip=
         "Hides the optional Notes Summary while Presentation Mode is active.",
     group="Display & Print",
     display=display.none
)


//======================================================================
// HEATMAP SETTINGS
//======================================================================

showHeatmap = input.bool(
     true,
     "Show Monthly Returns Heatmap",
     tooltip=
         "Shows or hides the year-by-month percentage returns heatmap.",
     group="Heatmap Table",
     display=display.none
)

showHeatmapTitle = input.bool(
     true,
     "Show Heatmap Title",
     tooltip=
         "Shows or hides the merged title row:\n\n" +
         "William Playfair's Monthly Returns Heatmap",
     group="Heatmap Table",
     display=display.none
)

heatmapPositionInput = input.string(
     "Bottom Left",
     "Heatmap Position",
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
         "Controls where the Monthly Returns Heatmap appears.\n\n" +
         "Default: Bottom Left.",
     group="Heatmap Table",
     display=display.none
)

heatmapFontInput = input.string(
     "Small",
     "Heatmap Text Size",
     options=[
         "Tiny",
         "Small",
         "Normal",
         "Large"
     ],
     tooltip=
         "Controls the heatmap text size.\n\n" +
         "Tiny can be useful when displaying many years.",
     group="Heatmap Table",
     display=display.none
)

titleFontInput = input.string(
     "Small",
     "Heatmap Title Size",
     options=[
         "Tiny",
         "Small",
         "Normal",
         "Large"
     ],
     tooltip=
         "Controls the merged heatmap title size.",
     group="Heatmap Table",
     display=display.none
)


//======================================================================
// SEASONAL TARGET TABLE SETTINGS
//======================================================================

showProjection = input.bool(
     true,
     "Show Seasonal Target Table",
     tooltip=
         "Shows or hides the current-month seasonal target analysis.",
     group="Seasonal Target Table",
     display=display.none
)

projectionPositionInput = input.string(
     "Bottom Right",
     "Target Table Position",
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
         "Controls where the Seasonal Target Table appears.\n\n" +
         "Default: Bottom Right.",
     group="Seasonal Target Table",
     display=display.none
)

projectionFontInput = input.string(
     "Small",
     "Target Table Text Size",
     options=[
         "Tiny",
         "Small",
         "Normal",
         "Large"
     ],
     tooltip=
         "Controls the Seasonal Target Table text size.",
     group="Seasonal Target Table",
     display=display.none
)

compactProjection = input.bool(
     false,
     "Compact Target Table",
     tooltip=
         "Compact mode displays only:\n\n" +
         "• Done This Month\n" +
         "• Historical Target\n" +
         "• Still To Go\n" +
         "• Status",
     group="Seasonal Target Table",
     display=display.none
)


//======================================================================
// HISTORY SETTINGS
//======================================================================

displayYearsInput = input.string(
     "All",
     "Years To Display",
     options=[
         "All",
         "3",
         "5",
         "7",
         "10",
         "15",
         "20"
     ],
     tooltip=
         "Controls how many calendar years appear in the heatmap.\n\n" +
         "ALL = display all usable history available to the script.",
     group="History",
     display=display.none
)

calculationYearsInput = input.string(
     "All",
     "Years For Seasonal Statistics",
     options=[
         "All",
         "3",
         "5",
         "7",
         "10",
         "15",
         "20"
     ],
     tooltip=
         "Controls how much history is used for seasonal calculations.\n\n" +
         "ALL = use all completed historical observations available to the script.",
     group="History",
     display=display.none
)


//======================================================================
// NOTES SUMMARY
//======================================================================

showNotesSummary = input.bool(
     false,
     "Show Notes Summary",
     tooltip=
         "Displays a compact current-month summary for reference when recording TradingView notes.",
     group="Notes Summary",
     display=display.none
)

notesPositionInput = input.string(
     "Top Right",
     "Notes Summary Position",
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
     group="Notes Summary",
     display=display.none
)

notesFontInput = input.string(
     "Tiny",
     "Notes Text Size",
     options=[
         "Tiny",
         "Small",
         "Normal",
         "Large"
     ],
     group="Notes Summary",
     display=display.none
)


//======================================================================
// EXPORT
//======================================================================

enableExportFields = input.bool(
     true,
     "Enable Export Fields",
     tooltip=
         "Makes key statistics available through TradingView's Data Window " +
         "and chart-data export without adding visible lines.",
     group="Export",
     display=display.none
)


//======================================================================
// COLOURS
//======================================================================

color targetBlue =
     color.rgb(20, 85, 180)

color bullGreen =
     color.rgb(0, 120, 40)

color bearRed =
     color.rgb(150, 15, 35)

color neutralGray =
     color.rgb(55, 55, 55)

color headerGray =
     color.rgb(25, 25, 25)

color labelGray =
     color.rgb(40, 40, 40)

color titleBackground =
     color.rgb(30, 55, 85)

color mainText =
     color.white

color emptyCell =
     color.new(color.gray, 85)


//======================================================================
// PRESENTATION COLOURS
//======================================================================

if presentationMode

    targetBlue :=
         color.rgb(190, 215, 245)

    bullGreen :=
         color.rgb(195, 230, 200)

    bearRed :=
         color.rgb(245, 195, 205)

    neutralGray :=
         color.rgb(220, 220, 220)

    headerGray :=
         color.rgb(200, 200, 200)

    labelGray :=
         color.rgb(230, 230, 230)

    titleBackground :=
         color.rgb(195, 215, 240)

    mainText :=
         color.black

    emptyCell :=
         color.rgb(245, 245, 245)


//======================================================================
// POSITION FUNCTION
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
// FONT FUNCTION
//======================================================================

getFontSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small


//======================================================================
// YEAR LIMIT FUNCTION
//======================================================================

getYearLimit(string selection) =>
    switch selection
        "3"  => 3
        "5"  => 5
        "7"  => 7
        "10" => 10
        "15" => 15
        "20" => 20
        => 0


//======================================================================
// RESOLVE SETTINGS
//======================================================================

displayYearLimit =
     getYearLimit(displayYearsInput)

calculationYearLimit =
     getYearLimit(calculationYearsInput)

heatmapPosition =
     getTablePosition(heatmapPositionInput)

projectionPosition =
     getTablePosition(projectionPositionInput)

notesPosition =
     getTablePosition(notesPositionInput)

heatmapFont =
     getFontSize(heatmapFontInput)

projectionFont =
     getFontSize(projectionFontInput)

notesFont =
     getFontSize(notesFontInput)

titleFont =
     getFontSize(titleFontInput)


//======================================================================
// MONTH NAME
//======================================================================

monthName(int m) =>
    switch m
        1  => "Jan"
        2  => "Feb"
        3  => "Mar"
        4  => "Apr"
        5  => "May"
        6  => "Jun"
        7  => "Jul"
        8  => "Aug"
        9  => "Sep"
        10 => "Oct"
        11 => "Nov"
        12 => "Dec"
        => ""


//======================================================================
// FORMAT PERCENTAGE
//======================================================================

fmtPct(float x) =>

    string result =
         "-"

    if not na(x)

        result :=
             str.tostring(
                 x,
                 "#.##"
             ) + "%"

    result


//======================================================================
// HEATMAP COLOUR
//======================================================================

heatColor(float x) =>

    color result =
         neutralGray

    if na(x)

        result :=
             emptyCell

    else if x >= 0

        result :=
             bullGreen

    else

        result :=
             bearRed

    result


//======================================================================
// STORAGE ARRAYS
//======================================================================

var array<int> yearsArr =
     array.new_int()

var array<int> monthsArr =
     array.new_int()

var array<float> returnsArr =
     array.new_float()


//======================================================================
// MONTHLY DATA
//======================================================================

mTime =
     request.security(
         syminfo.tickerid,
         "M",
         time
     )

mClose =
     request.security(
         syminfo.tickerid,
         "M",
         close
     )

mPrev =
     request.security(
         syminfo.tickerid,
         "M",
         close[1]
     )

monthlyReturnSeries =
     request.security(
         syminfo.tickerid,
         "M",
         ((close / close[1]) - 1.0) * 100.0
     )

newMonth =
     ta.change(mTime) != 0


//======================================================================
// STORE COMPLETED MONTHS
//======================================================================

if newMonth and not na(mPrev[1])

    completedYear =
         year(mTime[1])

    completedMonth =
         month(mTime[1])

    completedReturn =
         ((mClose[1] / mPrev[1]) - 1.0) * 100.0

    array.push(
         yearsArr,
         completedYear
     )

    array.push(
         monthsArr,
         completedMonth
     )

    array.push(
         returnsArr,
         completedReturn
     )


//======================================================================
// CURRENT MONTH RETURN
//======================================================================

float currentMonthReturn =
     na

if not na(mPrev)

    currentMonthReturn :=
         ((close / mPrev) - 1.0) * 100.0


//======================================================================
// EARLIEST AVAILABLE YEAR
//======================================================================

getEarliestYear() =>

    int earliest =
         year(time)

    if array.size(yearsArr) > 0

        earliest :=
             array.get(
                 yearsArr,
                 0
             )

        for i = 0 to array.size(yearsArr) - 1

            int yr =
                 array.get(
                     yearsArr,
                     i
                 )

            if yr < earliest

                earliest :=
                     yr

    earliest


earliestYear =
     getEarliestYear()


//======================================================================
// RETURN LOOKUP
//======================================================================

getReturn(
     int targetYear,
     int targetMonth
 ) =>

    float result =
         na

    if array.size(yearsArr) > 0

        for i = 0 to array.size(yearsArr) - 1

            int storedYear =
                 array.get(
                     yearsArr,
                     i
                 )

            int storedMonth =
                 array.get(
                     monthsArr,
                     i
                 )

            if storedYear == targetYear and
               storedMonth == targetMonth

                result :=
                     array.get(
                         returnsArr,
                         i
                     )

    result


//======================================================================
// YEAR RANGE FILTER
//======================================================================

yearIsInCalculationRange(
     int yr,
     int currentYr,
     int yearLimit
 ) =>

    bool valid =
         yr < currentYr

    if yearLimit > 0

        valid :=
             valid and
             yr >= currentYr - yearLimit

    valid


//======================================================================
// HISTORICAL AVERAGE
//======================================================================

getAverage(
     int targetMonth,
     int yearLimit
 ) =>

    float total =
         0.0

    int count =
         0

    int currentYr =
         year(time)

    if array.size(yearsArr) > 0

        for i = 0 to array.size(yearsArr) - 1

            int yr =
                 array.get(
                     yearsArr,
                     i
                 )

            int mo =
                 array.get(
                     monthsArr,
                     i
                 )

            float r =
                 array.get(
                     returnsArr,
                     i
                 )

            bool useYear =
                 yearIsInCalculationRange(
                     yr,
                     currentYr,
                     yearLimit
                 )

            if mo == targetMonth and useYear

                total += r

                count += 1

    float result =
         na

    if count > 0

        result :=
             total / count

    result


//======================================================================
// HISTORICAL MEDIAN
//======================================================================

getMedian(
     int targetMonth,
     int yearLimit
 ) =>

    array<float> vals =
         array.new_float()

    int currentYr =
         year(time)

    if array.size(yearsArr) > 0

        for i = 0 to array.size(yearsArr) - 1

            int yr =
                 array.get(
                     yearsArr,
                     i
                 )

            int mo =
                 array.get(
                     monthsArr,
                     i
                 )

            bool useYear =
                 yearIsInCalculationRange(
                     yr,
                     currentYr,
                     yearLimit
                 )

            if mo == targetMonth and useYear

                array.push(
                     vals,
                     array.get(
                         returnsArr,
                         i
                     )
                 )

    float result =
         na

    if array.size(vals) > 0

        array.sort(vals)

        int n =
             array.size(vals)

        if n % 2 == 1

            int middleIndex =
                 int(
                     math.floor(
                         n / 2
                     )
                 )

            result :=
                 array.get(
                     vals,
                     middleIndex
                 )

        else

            float lowerValue =
                 array.get(
                     vals,
                     n / 2 - 1
                 )

            float upperValue =
                 array.get(
                     vals,
                     n / 2
                 )

            result :=
                 (lowerValue + upperValue) / 2.0

    result


//======================================================================
// POSITIVE-YEAR RATE
//======================================================================

getWinRate(
     int targetMonth,
     int yearLimit
 ) =>

    int wins =
         0

    int count =
         0

    int currentYr =
         year(time)

    if array.size(yearsArr) > 0

        for i = 0 to array.size(yearsArr) - 1

            int yr =
                 array.get(
                     yearsArr,
                     i
                 )

            int mo =
                 array.get(
                     monthsArr,
                     i
                 )

            float r =
                 array.get(
                     returnsArr,
                     i
                 )

            bool useYear =
                 yearIsInCalculationRange(
                     yr,
                     currentYr,
                     yearLimit
                 )

            if mo == targetMonth and useYear

                count += 1

                if r > 0

                    wins += 1

    float result =
         na

    if count > 0

        result :=
             100.0 * wins / count

    result


//======================================================================
// SAMPLE SIZE
//======================================================================

getSample(
     int targetMonth,
     int yearLimit
 ) =>

    int count =
         0

    int currentYr =
         year(time)

    if array.size(yearsArr) > 0

        for i = 0 to array.size(yearsArr) - 1

            int yr =
                 array.get(
                     yearsArr,
                     i
                 )

            int mo =
                 array.get(
                     monthsArr,
                     i
                 )

            bool useYear =
                 yearIsInCalculationRange(
                     yr,
                     currentYr,
                     yearLimit
                 )

            if mo == targetMonth and useYear

                count += 1

    count


//======================================================================
// CURRENT MONTH STATISTICS
//======================================================================

currentMonth =
     month(time)

histAverage =
     getAverage(
         currentMonth,
         calculationYearLimit
     )

histMedian =
     getMedian(
         currentMonth,
         calculationYearLimit
     )

winRate =
     getWinRate(
         currentMonth,
         calculationYearLimit
     )

sampleSize =
     getSample(
         currentMonth,
         calculationYearLimit
     )


//======================================================================
// TARGET PRICE
//======================================================================

float targetPrice =
     na

if not na(mPrev) and
   not na(histAverage)

    targetPrice :=
         mPrev *
         (1.0 + histAverage / 100.0)


//======================================================================
// STILL TO GO
//======================================================================

float remainingMove =
     na

if not na(targetPrice)

    remainingMove :=
         ((targetPrice / close) - 1.0) * 100.0


//======================================================================
// CURRENT MONTH COLOUR
//======================================================================

color currentMoveColor =
     neutralGray

if not na(currentMonthReturn)

    if currentMonthReturn >= 0

        currentMoveColor :=
             bullGreen

    else

        currentMoveColor :=
             bearRed


//======================================================================
// POSITIVE-YEAR COLOUR
//======================================================================

color winRateColor =
     neutralGray

if not na(winRate)

    if winRate >= 50

        winRateColor :=
             bullGreen

    else

        winRateColor :=
             bearRed


//======================================================================
// SEASONAL STATUS
//======================================================================

string status =
     "No Data"

if not na(currentMonthReturn) and
   not na(histAverage)

    if histAverage > 0

        if currentMonthReturn >= histAverage

            status :=
                 "Bullish Target Exceeded"

        else

            status :=
                 "Bullish Target Remaining"

    else if histAverage < 0

        if currentMonthReturn <= histAverage

            status :=
                 "Bearish Target Exceeded"

        else

            status :=
                 "Bearish Target Remaining"

    else

        status :=
             "Historically Flat"


//======================================================================
// STATUS COLOUR
//======================================================================

color statusColor =
     neutralGray

if not na(histAverage)

    if histAverage >= 0

        statusColor :=
             bullGreen

    else

        statusColor :=
             bearRed


//======================================================================
// LABELS
//======================================================================

string calculationLabel =
     ""

if calculationYearsInput == "All"

    calculationLabel :=
         "All Avg"

else

    calculationLabel :=
         calculationYearsInput + "Y Avg"


string targetLabel =
     ""

if calculationYearsInput == "All"

    targetLabel :=
         "All-History Target %"

else

    targetLabel :=
         calculationYearsInput + "Y Target %"


string medianLabel =
     ""

if calculationYearsInput == "All"

    medianLabel :=
         "All-History Median"

else

    medianLabel :=
         calculationYearsInput + "Y Median"


//======================================================================
// DISPLAY YEARS
//======================================================================

availableDisplayYears =
     year(time) - earliestYear + 1

int requestedDisplayYears =
     availableDisplayYears

if displayYearLimit > 0

    requestedDisplayYears :=
         math.min(
             displayYearLimit,
             availableDisplayYears
         )

yearsToDraw =
     math.min(
         requestedDisplayYears,
         MAX_DISPLAY_YEARS
     )


//======================================================================
// TARGET PRICE TEXT
//======================================================================

string targetPriceText =
     "-"

if not na(targetPrice)

    targetPriceText :=
         str.tostring(
             targetPrice,
             format.mintick
         )


//======================================================================
// NOTES SUMMARY
//======================================================================

string notesSummary =
     ""

notesSummary :=
     "Monthly Returns Heatmap & Seasonal Targets" +
     "\n" +
     "Author: William Playfair" +
     "\n" +
     syminfo.ticker +
     " | " +
     monthName(currentMonth) +
     "\n" +
     "Current Month: " +
     fmtPct(currentMonthReturn) +
     "\n" +
     "Historical Avg: " +
     fmtPct(histAverage) +
     "\n" +
     "Historical Median: " +
     fmtPct(histMedian) +
     "\n" +
     "Positive Years: " +
     fmtPct(winRate) +
     "\n" +
     "Target Price: " +
     targetPriceText +
     "\n" +
     "Still To Go: " +
     fmtPct(remainingMove) +
     "\n" +
     "Historical Sample: " +
     str.tostring(sampleSize) +
     " years" +
     "\n" +
     "Status: " +
     status +
     "\n\n" +
     "Seasonal target values are historical references, not forecasts."


//======================================================================
// CREATE TABLES
//======================================================================

var table heatmap =
     table.new(
         heatmapPosition,
         13,
         MAX_DISPLAY_YEARS + 3,
         border_width=1,
         force_overlay=true
     )


var table projection =
     table.new(
         projectionPosition,
         2,
         9,
         border_width=1,
         force_overlay=true
     )


var table notesTable =
     table.new(
         notesPosition,
         1,
         1,
         border_width=1,
         force_overlay=true
     )


//======================================================================
// MERGE ENTIRE HEATMAP TITLE ROW
//======================================================================

if barstate.isfirst

    table.merge_cells(
         heatmap,
         0,
         0,
         12,
         0
     )


//======================================================================
// VISIBILITY
//======================================================================

bool drawProjection =
     showProjection

bool drawNotes =
     showNotesSummary


if presentationMode and
   hideTargetInPresentation

    drawProjection :=
         false


if presentationMode and
   hideNotesInPresentation

    drawNotes :=
         false


//======================================================================
// DRAW TABLES
//======================================================================

if barstate.islast

    table.clear(
         heatmap,
         0,
         0,
         12,
         MAX_DISPLAY_YEARS + 2
     )

    table.clear(
         projection,
         0,
         0,
         1,
         8
     )

    table.clear(
         notesTable,
         0,
         0,
         0,
         0
     )


    //==================================================================
    // MONTHLY RETURNS HEATMAP
    //==================================================================

    if showHeatmap

        //--------------------------------------------------------------
        // MERGED TITLE
        //--------------------------------------------------------------

        if showHeatmapTitle

            table.cell(
                 heatmap,
                 0,
                 0,
                 "William Playfair's Monthly Returns Heatmap",
                 bgcolor=titleBackground,
                 text_color=mainText,
                 text_size=titleFont,
                 text_halign=text.align_center
             )

        else

            table.cell(
                 heatmap,
                 0,
                 0,
                 "",
                 bgcolor=color.new(titleBackground, 100),
                 text_color=mainText,
                 text_size=titleFont
             )


        //--------------------------------------------------------------
        // MONTH HEADINGS
        //--------------------------------------------------------------

        table.cell(
             heatmap,
             0,
             1,
             syminfo.ticker,
             bgcolor=headerGray,
             text_color=mainText,
             text_size=heatmapFont
         )

        for mo = 1 to 12

            table.cell(
                 heatmap,
                 mo,
                 1,
                 monthName(mo),
                 bgcolor=headerGray,
                 text_color=mainText,
                 text_size=heatmapFont
             )


        //--------------------------------------------------------------
        // HISTORICAL AVERAGE
        //--------------------------------------------------------------

        table.cell(
             heatmap,
             0,
             2,
             calculationLabel,
             bgcolor=targetBlue,
             text_color=mainText,
             text_size=heatmapFont
         )

        for mo = 1 to 12

            float avgReturn =
                 getAverage(
                     mo,
                     calculationYearLimit
                 )

            table.cell(
                 heatmap,
                 mo,
                 2,
                 fmtPct(avgReturn),
                 bgcolor=targetBlue,
                 text_color=mainText,
                 text_size=heatmapFont
             )


        //--------------------------------------------------------------
        // YEAR ROWS
        //--------------------------------------------------------------

        thisYear =
             year(time)

        if yearsToDraw > 0

            for row = 0 to yearsToDraw - 1

                yr =
                     thisYear - row

                tableRow =
                     row + 3

                table.cell(
                     heatmap,
                     0,
                     tableRow,
                     str.tostring(yr),
                     bgcolor=headerGray,
                     text_color=mainText,
                     text_size=heatmapFont
                 )

                for mo = 1 to 12

                    float monthlyValue =
                         getReturn(
                             yr,
                             mo
                         )


                    //--------------------------------------------------
                    // LIVE CURRENT MONTH
                    //--------------------------------------------------

                    if yr == thisYear and
                       mo == currentMonth

                        monthlyValue :=
                             currentMonthReturn


                    //--------------------------------------------------
                    // FUTURE MONTHS
                    //--------------------------------------------------

                    if yr == thisYear and
                       mo > currentMonth

                        monthlyValue :=
                             na


                    table.cell(
                         heatmap,
                         mo,
                         tableRow,
                         fmtPct(monthlyValue),
                         bgcolor=heatColor(monthlyValue),
                         text_color=mainText,
                         text_size=heatmapFont
                     )


    //==================================================================
    // SEASONAL TARGET TABLE
    //==================================================================

    if drawProjection

        //--------------------------------------------------------------
        // TITLE
        //--------------------------------------------------------------

        table.cell(
             projection,
             0,
             0,
             syminfo.ticker +
             " " +
             monthName(currentMonth),
             bgcolor=headerGray,
             text_color=mainText,
             text_size=projectionFont
         )

        table.cell(
             projection,
             1,
             0,
             "Seasonality",
             bgcolor=headerGray,
             text_color=mainText,
             text_size=projectionFont
         )


        //--------------------------------------------------------------
        // DONE THIS MONTH
        //--------------------------------------------------------------

        table.cell(
             projection,
             0,
             1,
             "Done This Month",
             bgcolor=labelGray,
             text_color=mainText,
             text_size=projectionFont
         )

        table.cell(
             projection,
             1,
             1,
             fmtPct(currentMonthReturn),
             bgcolor=currentMoveColor,
             text_color=mainText,
             text_size=projectionFont
         )


        //--------------------------------------------------------------
        // HISTORICAL TARGET %
        //--------------------------------------------------------------

        table.cell(
             projection,
             0,
             2,
             targetLabel,
             bgcolor=labelGray,
             text_color=mainText,
             text_size=projectionFont
         )

        table.cell(
             projection,
             1,
             2,
             fmtPct(histAverage),
             bgcolor=targetBlue,
             text_color=mainText,
             text_size=projectionFont
         )


        //--------------------------------------------------------------
        // COMPACT MODE
        //--------------------------------------------------------------

        if compactProjection

            table.cell(
                 projection,
                 0,
                 3,
                 "Still To Go",
                 bgcolor=labelGray,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 1,
                 3,
                 fmtPct(remainingMove),
                 bgcolor=targetBlue,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 0,
                 4,
                 "Status",
                 bgcolor=labelGray,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 1,
                 4,
                 status,
                 bgcolor=statusColor,
                 text_color=mainText,
                 text_size=projectionFont
             )


        //--------------------------------------------------------------
        // FULL MODE
        //--------------------------------------------------------------

        else

            table.cell(
                 projection,
                 0,
                 3,
                 medianLabel,
                 bgcolor=labelGray,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 1,
                 3,
                 fmtPct(histMedian),
                 bgcolor=targetBlue,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 0,
                 4,
                 "Positive Years",
                 bgcolor=labelGray,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 1,
                 4,
                 fmtPct(winRate),
                 bgcolor=winRateColor,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 0,
                 5,
                 "Target Price",
                 bgcolor=labelGray,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 1,
                 5,
                 targetPriceText,
                 bgcolor=targetBlue,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 0,
                 6,
                 "Still To Go",
                 bgcolor=labelGray,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 1,
                 6,
                 fmtPct(remainingMove),
                 bgcolor=targetBlue,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 0,
                 7,
                 "Historical Sample",
                 bgcolor=labelGray,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 1,
                 7,
                 str.tostring(sampleSize) +
                 " years",
                 bgcolor=neutralGray,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 0,
                 8,
                 "Seasonal Status",
                 bgcolor=labelGray,
                 text_color=mainText,
                 text_size=projectionFont
             )

            table.cell(
                 projection,
                 1,
                 8,
                 status,
                 bgcolor=statusColor,
                 text_color=mainText,
                 text_size=projectionFont
             )


    //==================================================================
    // NOTES SUMMARY
    //==================================================================

    if drawNotes

        table.cell(
             notesTable,
             0,
             0,
             notesSummary,
             bgcolor=labelGray,
             text_color=mainText,
             text_size=notesFont,
             text_halign=text.align_left,
             text_valign=text.align_top
         )


//======================================================================
// EXPORT / DATA WINDOW
//======================================================================

float exportMonthlyReturn =
     na

float exportCurrentMonth =
     na

float exportAverage =
     na

float exportMedian =
     na

float exportWinRate =
     na

float exportTargetPrice =
     na

float exportStillToGo =
     na


if enableExportFields

    exportMonthlyReturn :=
         monthlyReturnSeries

    exportCurrentMonth :=
         currentMonthReturn

    exportAverage :=
         histAverage

    exportMedian :=
         histMedian

    exportWinRate :=
         winRate

    exportTargetPrice :=
         targetPrice

    exportStillToGo :=
         remainingMove


plot(
     exportMonthlyReturn,
     title="EXPORT - Monthly Return %",
     display=display.data_window
)

plot(
     exportCurrentMonth,
     title="EXPORT - Current Month %",
     display=display.data_window
)

plot(
     exportAverage,
     title="EXPORT - Historical Average %",
     display=display.data_window
)

plot(
     exportMedian,
     title="EXPORT - Historical Median %",
     display=display.data_window
)

plot(
     exportWinRate,
     title="EXPORT - Positive Years %",
     display=display.data_window
)

plot(
     exportTargetPrice,
     title="EXPORT - Seasonal Target Price",
     display=display.data_window
)

plot(
     exportStillToGo,
     title="EXPORT - Still To Go %",
     display=display.data_window
)
````
